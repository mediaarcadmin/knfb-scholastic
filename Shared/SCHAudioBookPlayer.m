//
//  SCHAudioBookPlayer.m
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioBookPlayer.h"

#import "SCHWordTimingProcessor.h"
#import "SCHAudioInfoProcessor.h"
#import "SCHWordTiming.h"

static NSTimeInterval const kSCHAudioBookPlayerMilliSecondsInASecond = 1000.0;

@interface SCHAudioBookPlayer ()

@property (nonatomic, retain) AVAudioPlayer *player;  
@property (nonatomic, retain) NSArray *audioInfo;  
@property (nonatomic, retain) NSArray *wordTimings;  
@property (nonatomic, assign) BOOL resumeInterruptedPlayer;
@property (nonatomic, assign) dispatch_source_t timer;

@end

@implementation SCHAudioBookPlayer

@synthesize delegate;
@synthesize player;
@synthesize audioInfo;
@synthesize wordTimings;
@synthesize resumeInterruptedPlayer;
@synthesize timer;
@dynamic playing;

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        resumeInterruptedPlayer = NO;
        timer = NULL;
    }
    return(self);
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (timer != NULL) {
        dispatch_release(timer), timer = NULL;
    }
    
    [player release], player = nil;
    [audioInfo release], audioInfo = nil;
    [wordTimings release], wordTimings = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (BOOL)prepareToPlay:(NSData *)audioData audioInfoData:(NSData *)audioInfoData 
   wordTimingFileData:(NSData *)wordTimingData 
                error:(NSError **)outError wordBlock:(WordBlock)wordBlock
{    
    BOOL ret = NO;
    
    if (audioData != nil && wordTimingData != nil) {
        self.player = [[AVAudioPlayer alloc] initWithData:audioData error:outError];
        if (self.player != nil) {
            [self.player release];
            self.player.delegate = self;
            ret = [self.player prepareToPlay];
            if (ret == YES) {
                SCHAudioInfoProcessor *audioInfoProcessor = [[SCHAudioInfoProcessor alloc] init];
                self.audioInfo = [audioInfoProcessor audioInfoFrom:audioInfoData error:outError];
                [audioInfoProcessor release], audioInfoProcessor = nil;
                self.wordTimings = [SCHWordTimingProcessor startTimesFrom:wordTimingData error:outError];
                
                if ([wordTimings count] < 1) {
                    ret = NO;
                } else {
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(willResignActiveNotification:)
                                                                 name:UIApplicationWillResignActiveNotification
                                                               object:nil];            
                    
                    dispatch_queue_t q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q_default); //run event handler on the default global queue
                    dispatch_time_t now = dispatch_walltime(DISPATCH_TIME_NOW, 0);
                    dispatch_source_set_timer(self.timer, now, 4 * NSEC_PER_MSEC, NSEC_PER_MSEC);
                    dispatch_source_set_event_handler(self.timer, ^{                
                        static NSUInteger currentPosition = 0;
                        static SCHWordTiming *lastTriggered = nil;
                        
                        // We're using the WordTimings file use of integers for time
                        NSUInteger currentPlayTime = (NSUInteger)(self.player.currentTime * kSCHAudioBookPlayerMilliSecondsInASecond);
                        SCHWordTiming *wordTiming = [self.wordTimings objectAtIndex:currentPosition];
                        
                        switch ([wordTiming compareTime:currentPlayTime]) {
                            case NSOrderedSame:
                                // nop - we got our match
                                break;
                            case NSOrderedAscending:
                                // fast forward
                                for (NSUInteger i = currentPosition + 1; i < [self.wordTimings count]; i++) {
                                    wordTiming = [self.wordTimings objectAtIndex:i];
                                    NSComparisonResult result = [wordTiming compareTime:currentPlayTime];
                                    if (result == NSOrderedSame) {
                                        currentPosition = i;
                                        break;
                                    } else if (result == NSOrderedDescending) {
                                        break;
                                    }
                                }
                                break;
                            case NSOrderedDescending:
                                // rewind
                                if (currentPosition > 0) {
                                    for (NSUInteger i = currentPosition - 1; i > 0; i--) {
                                        wordTiming = [self.wordTimings objectAtIndex:i];
                                        NSComparisonResult result = [wordTiming compareTime:currentPlayTime];                                    
                                        if (result == NSOrderedSame) {
                                            currentPosition = i;
                                            break;
                                        } else if (result == NSOrderedAscending) {
                                            break;
                                        }
                                    }
                                }
                                break;                                
                        }  
                        
                        if (wordTiming != lastTriggered && [wordTiming compareTime:currentPlayTime] == NSOrderedSame) {
                            lastTriggered = wordTiming;
                            wordBlock(currentPosition);
                        }                                                
                    });
                }
            }
        }
    }
    
    return(ret);
}

- (BOOL)play
{
    BOOL ret = NO;
    
    ret = [self.player play];
    if (ret == YES && self.timer != NULL) {
        dispatch_resume(self.timer);        
    }

    return(ret);
}

- (BOOL)playAtIndex:(NSUInteger)index
{  
    BOOL ret = NO;

    if (index < [self.wordTimings count]) {
        SCHWordTiming *wordTiming = [self.wordTimings objectAtIndex:index];
        self.player.currentTime = [wordTiming startTimeAsSeconds];
        ret = [self play];
    }
    
    return(ret);
}

- (void)pause
{
    if (self.timer != NULL) {
        dispatch_suspend(self.timer);
    }
    [self.player pause];
}

- (void)stop
{
    if (self.timer != NULL) {
        dispatch_release(self.timer), self.timer = NULL;
    }
    [self.player stop];
}

- (BOOL)playing
{
    return(self.player.playing);
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self pause];
}

#pragma mark - AVAudioPlayer Delegate methods

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.player.playing == YES) {
        [self.player pause];
        self.resumeInterruptedPlayer = YES;
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    if (self.resumeInterruptedPlayer == YES) {
        self.resumeInterruptedPlayer = NO;
        [self play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.timer != NULL) {
        dispatch_suspend(self.timer);
    }
	if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerDidFinishPlaying:successfully:)]) {
        [(id)self.delegate audioBookPlayerDidFinishPlaying:self successfully:flag];
	}    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (self.timer != NULL) {
        dispatch_suspend(self.timer);
    }
    if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerErrorDidOccur:error:)]) {
        [(id)self.delegate audioBookPlayerErrorDidOccur:self error:error];
    }     
}

@end
