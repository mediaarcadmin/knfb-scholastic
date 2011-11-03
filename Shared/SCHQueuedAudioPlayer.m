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

- (void)executeStartBlockOnQueue:(dispatch_queue_t)queue;
- (void)executeEndBlockOnQueue:(dispatch_queue_t)queue;
@end

@interface SCHQueuedAudioPlayer ()

@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *audioQueue;
@property (nonatomic, assign) NSTimeInterval gap;
@property (nonatomic, retain) AudioItem *currentItem;
@property (nonatomic, assign) dispatch_queue_t audioDispatchQueue;
@property (nonatomic, assign) BOOL appInBackground;

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data;
- (void)playNextItemInQueue;

@end

@implementation SCHQueuedAudioPlayer

@synthesize synchronizedBlockQueue;
@synthesize audioPlayer;
@synthesize audioQueue;
@synthesize gap;
@synthesize currentItem;
@synthesize audioDispatchQueue;
@synthesize appInBackground;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.audioPlayer.delegate = nil;
    [self.audioPlayer pause];
    [audioPlayer release], audioPlayer = nil;
    [audioQueue release];
    [currentItem release];
    dispatch_release(audioDispatchQueue);
    dispatch_release(synchronizedBlockQueue);
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.audioQueue = [NSMutableArray array];
        self.audioDispatchQueue = dispatch_queue_create("com.bitwink.SCHQueuedAudioPlayer", 0);
        self.gap = 0;
        self.synchronizedBlockQueue = dispatch_get_main_queue();
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        self.appInBackground = NO;
    }
    return self;
}

#pragma mark - Background notifications

- (void)willResignActiveNotification: (NSNotification *)notification
{
    if (self.audioPlayer && [self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
        NSLog(@"Pausing audio.");
    }
    self.appInBackground = YES;
}

- (void)didBecomeActiveNotification: (NSNotification *)notification
{
    if (self.audioPlayer && self.appInBackground) {
        NSLog(@"Resuming audio.");
        [self.audioPlayer play];
    }
    
    self.appInBackground = NO;
}

- (void)setSynchronizedBlockQueue:(dispatch_queue_t)aSynchronizedBlockQueue
{
    if (aSynchronizedBlockQueue != synchronizedBlockQueue) {
        if (synchronizedBlockQueue) {
            dispatch_release(synchronizedBlockQueue);
        }
        synchronizedBlockQueue = aSynchronizedBlockQueue ?: dispatch_get_main_queue();
        dispatch_retain(synchronizedBlockQueue);
    }
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
    
    
    
    dispatch_async(self.audioDispatchQueue, ^{
        [self.audioQueue addObject:item];
        if (self.currentItem == nil && [self.audioQueue count] == 1) {
            [self playNextItemInQueue];
        }
    });
        
    [item release];
    self.gap = 0;
}

- (void)enqueueAudioTaskWithFetchBlock:(SCHQueuedAudioPlayerFetchBlock)fetchBlock
                synchronizedStartBlock:(dispatch_block_t)startBlock
                  synchronizedEndBlock:(dispatch_block_t)endBlock
                    requiresEmptyQueue:(BOOL)requiresEmpty
{
    
    AudioItem *item = [[AudioItem alloc] init];
    item.startDelay = self.gap;
    item.fetchBlock = fetchBlock;
    item.startBlock = startBlock;
    item.endBlock = endBlock;
    
    void (^enqueingBlock)(void) = ^{
        [self.audioQueue addObject:item];
        if (self.currentItem == nil && [self.audioQueue count] == 1) {
            [self playNextItemInQueue];
        }
    };
    
    if (requiresEmpty) {
        dispatch_async(self.audioDispatchQueue, ^{
            if ([self.audioQueue count] == 0) {
                enqueingBlock();
            }
        });
    } else {
        dispatch_async(self.audioDispatchQueue, enqueingBlock);
    }
    
    [item release];
    self.gap = 0;
}

- (void)enqueueGap:(NSTimeInterval)silenceInterval
{
    self.gap += silenceInterval;
}

- (void)cancelPlaybackExecutingSynchronizedBlocks:(BOOL)executeBlocks beforeCompletionHandler:(dispatch_block_t)completion
{
    dispatch_async(self.audioDispatchQueue, ^{
        [self.audioPlayer pause];
        if (executeBlocks) {
            [self.currentItem executeEndBlockOnQueue:self.synchronizedBlockQueue];
            for (AudioItem *item in self.audioQueue) {
                [item executeStartBlockOnQueue:self.synchronizedBlockQueue];
                [item executeEndBlockOnQueue:self.synchronizedBlockQueue];
            }
        }
        
        [self.audioQueue removeAllObjects];
        if (self.audioPlayer) {
            self.audioPlayer.delegate = nil;
            self.currentItem = nil;
            [self.audioPlayer pause];
            self.audioPlayer = nil;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

- (BOOL)isPlaying
{
    return self.audioPlayer != nil && self.audioPlayer.playing;
}

- (void)playNextItemInQueue
{
    NSAssert(dispatch_get_current_queue() == self.audioDispatchQueue, @"must playNextItemInQueue on audioDispatchQueue");
    
    NSData *data = nil;
    while ([self.audioQueue count] > 0) {
        self.currentItem = [self.audioQueue objectAtIndex:0];
        [self.audioQueue removeObjectAtIndex:0];
        data = self.currentItem.fetchBlock();
        if (data) {
            break;
        }
        
        [currentItem executeStartBlockOnQueue:self.synchronizedBlockQueue];
        [currentItem executeEndBlockOnQueue:self.synchronizedBlockQueue];
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
        if (self.appInBackground) {
            [self.audioPlayer pause];
        } else {
            [self.audioPlayer play];
        }
        [self.currentItem executeStartBlockOnQueue:self.synchronizedBlockQueue];
    };
    
    if (self.currentItem.startDelay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.currentItem.startDelay*NSEC_PER_SEC), self.audioDispatchQueue, playBlock);
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
    dispatch_async(self.audioDispatchQueue, ^{
        AudioItem *item = [self.currentItem retain];
        self.currentItem = nil;
        self.audioPlayer.delegate = nil;
        self.audioPlayer = nil;

        [item executeEndBlockOnQueue:self.synchronizedBlockQueue];
        [item release];
    
        // only progress with the queue if the end block did not enqueue a new item
        if (!self.currentItem) {
            [self playNextItemInQueue];
        }
    });
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur: %@", [error localizedDescription]);
    [self audioPlayerDidFinishPlaying:player successfully:NO];
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

- (void)executeStartBlockOnQueue:(dispatch_queue_t)queue
{
    if (self.startBlock) {
        dispatch_async(queue, self.startBlock);
        self.startBlock = nil;
    }
}

- (void)executeEndBlockOnQueue:(dispatch_queue_t)queue
{
    if (self.endBlock) {
        dispatch_async(queue, self.endBlock);
        self.endBlock = nil;
    }
}

@end
