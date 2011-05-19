//
//  SCHAudioBookPlayer.m
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioBookPlayer.h"

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVTime.h>

#import "SCHWordTiming.h"

static int32_t const kSCHAudioBookPlayerMilliSecondTimescale = 1000;

@interface SCHAudioBookPlayer ()

@property (nonatomic, retain) NSURL *audioFile;  
@property (nonatomic, retain) AVPlayer *player;  
@property (nonatomic, retain) id timeObserver;  
@property (nonatomic, retain) SCHWordTiming *wordTiming;  

@end

@implementation SCHAudioBookPlayer

@synthesize delegate;
@synthesize audioFile;
@synthesize player;
@synthesize timeObserver;
@synthesize wordTiming;

- (id)initWithAudioFile:(NSURL *)aAudioFile wordTimingFilePath:(NSString *)aWordTimingFilePath 
{
    self = [super init];
    if (self) {
        wordTiming = [[SCHWordTiming alloc] initWithWordTimingFilePath:aWordTimingFilePath];
        audioFile = [aAudioFile retain];
    }
    return(self);
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [audioFile release], audioFile = nil;
    [player removeObserver:self forKeyPath:@"status"];
    [player removeTimeObserver:timeObserver];
    [player release], player = nil;
    [timeObserver release], timeObserver = nil;    
    [wordTiming release], wordTiming = nil;
    
    [super dealloc];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	if([notification object] == self.player && 
       [(id)self.delegate respondsToSelector:@selector(audioBookPlayerDidFinishPlaying:successfully:)]) {
			[(id)self.delegate audioBookPlayerDidFinishPlaying:self successfully:YES];
	}
}

- (void)playerItemFailedToReachEnd:(NSNotification *)notification
{
	if([notification object] == self.player && 
       [(id)self.delegate respondsToSelector:@selector(audioBookPlayerDidFinishPlaying:successfully:)]) {
        [(id)self.delegate audioBookPlayerDidFinishPlaying:self successfully:NO];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context 
{
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [player play];
        } else if(player.status == AVPlayerStatusFailed) {
            if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerErrorDidOccur:error:)]) {
                [(id)self.delegate audioBookPlayerErrorDidOccur:self error:player.error];
            }            
        }
    }
}

- (BOOL)playAtTime:(NSUInteger)milliseconds
{    
    [player seekToTime:CMTimeMake(milliseconds, kSCHAudioBookPlayerMilliSecondTimescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    return([self play]);
}

- (BOOL)play
{
    if (self.player == nil) {
        self.player = [AVPlayer playerWithURL:self.audioFile];
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemFailedToReachEnd:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.player.currentItem];
        
        NSError *error = nil;
        NSArray *times = [self.wordTiming startTimes:&error];   
        if (error == nil) {
            self.timeObserver = [player addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
                static NSUInteger index = 0;
                index++;
                NSLog(@"%lu %@", (unsigned long)index, CMTimeCopyDescription(NULL, player.currentTime));
            }];
        }
    } else {
        [self.player play];
    }
    
    return(YES);
}

- (void)pause
{
    [self.player pause];
}

@end
