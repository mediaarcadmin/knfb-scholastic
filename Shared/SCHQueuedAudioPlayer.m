//
//  SCHQueuedAudioPlayer.m
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHQueuedAudioPlayer.h"

@interface AudioItem : NSObject {}
@property (nonatomic, assign) NSTimeInterval startDelay;
@property (nonatomic, copy) SCHQueuedAudioPlayerFetchBlock fetchBlock;
@property (nonatomic, copy) dispatch_block_t startBlock;
@property (nonatomic, copy) dispatch_block_t endBlock;

- (void) executeStartBlock;
- (void) executeEndBlock;
@end

@interface SCHQueuedAudioPlayer ()

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *audioQueue;
@property (nonatomic, assign) NSTimeInterval gap;
@property (nonatomic, retain) AudioItem *currentItem;

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data;
- (void)playNextItemInQueue;

@end

@implementation SCHQueuedAudioPlayer

@synthesize audioPlayer;
@synthesize audioQueue;
@synthesize gap;
@synthesize currentItem;

- (void)dealloc
{
    [self cancelExecutingSynchronizedBlocksImmediately:NO];
    [audioPlayer release];
    [audioQueue release];
    [currentItem release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.audioQueue = [NSMutableArray array];
        self.gap = 0;
    }
    return self;
}

- (void)enqueueAudioTaskWithFetchBlock:(SCHQueuedAudioPlayerFetchBlock)fetchBlock
                synchronizedStartBlock:(dispatch_block_t)startBlock
                  synchronizedEndBlock:(dispatch_block_t)endBlock
{
    AudioItem *item = [[AudioItem alloc] init];
    item.startDelay = self.gap;
    item.fetchBlock = fetchBlock;
    item.startBlock = startBlock;
    item.endBlock = endBlock;
    [self.audioQueue addObject:item];
    [item release];
    self.gap = 0;
    
    if (self.currentItem == nil && [self.audioQueue count] == 1) {
        [self playNextItemInQueue];
    }
}

- (void)enqueueGap:(NSTimeInterval)silenceInterval
{
    self.gap += silenceInterval;
}

- (void)cancelExecutingSynchronizedBlocksImmediately:(BOOL)executeBlocks
{
    [self.audioPlayer pause];
    if (executeBlocks) {
        [self.currentItem executeEndBlock];
        for (AudioItem *item in self.audioQueue) {
            [item executeStartBlock];
            [item executeEndBlock];
        }
    }
    
    [self.audioQueue removeAllObjects];
    if (self.audioPlayer) {
        self.audioPlayer.delegate = nil;
        self.currentItem = nil;
        [self.audioPlayer pause];
        self.audioPlayer = nil;
    }
}

- (BOOL)isPlaying
{
    return self.audioPlayer != nil && self.audioPlayer.playing;
}

- (void)playNextItemInQueue
{
    NSData *data = nil;
    while ([self.audioQueue count] > 0) {
        self.currentItem = [self.audioQueue objectAtIndex:0];
        [self.audioQueue removeObjectAtIndex:0];
        data = self.currentItem.fetchBlock();
        
        if (data == nil) {
            [currentItem executeStartBlock];
            [currentItem executeEndBlock];
        } else {
            break;
        }
    }
    
    if (data == nil) {
        self.currentItem = nil;
        return;
    }
    
    AVAudioPlayer *player = [self newAudioPlayerWithData:data];
    player.delegate = self;
    self.audioPlayer = player;
    [player release];

    dispatch_block_t playBlock = ^{
        [self.currentItem executeStartBlock];
        [self.audioPlayer play];
    };
    
    if (self.currentItem.startDelay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.currentItem.startDelay*NSEC_PER_SEC), dispatch_get_main_queue(), playBlock);
    } else {
        playBlock();
    }
}

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data
{
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (!player) {
        NSLog(@"failed to create player: %@", error);
    }
    return player;
}

#pragma - AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (player == self.audioPlayer && player.playing) {
        [player pause];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    if (player == self.audioPlayer && player.playing) {
        [player play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // the endBlock could conceivably result in the dealloc of the
    // player, so retain self until the empty queue check is done
    [self retain];

    dispatch_block_t endBlock = nil;
    if (self.currentItem && self.currentItem.endBlock != nil) {
        endBlock = Block_copy(self.currentItem.endBlock);
    }
    self.currentItem = nil;
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    
    if (endBlock) {
        endBlock();
        Block_release(endBlock);
    }
    
    // only progress with the queue if the end block did not enqueue a new item
    if (!self.audioPlayer) {
        [self playNextItemInQueue];
    }
    
    [self release];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil]; 
    [errorAlert show]; 
    [errorAlert release]; 
}

@end


@implementation AudioItem

@synthesize fetchBlock;
@synthesize startDelay;
@synthesize startBlock;
@synthesize endBlock;

- (void)dealloc
{
    [fetchBlock release];
    [startBlock release];
    [endBlock release];
    [super dealloc];
}

- (void) executeStartBlock
{
    if (self.startBlock) {
        self.startBlock();
    }
    self.startBlock = nil;
}
- (void) executeEndBlock
{
    if (self.endBlock) {
        self.endBlock();
    }
    self.endBlock = nil;
}

@end
