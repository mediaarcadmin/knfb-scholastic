//
//  SCHAudioBookPlayer.m
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioBookPlayer.h"

#import "SCHWordTimingProcessor.h"
#import "SCHWordTiming.h"
#import "SCHAudioInfoProcessor.h"
#import "SCHAudioInfo.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"
#import "SCHAppBook.h"

static NSTimeInterval const kSCHAudioBookPlayerMilliSecondsInASecond = 1000.0;
static NSInteger const kSCHAudioBookPlayerWordTimerInterval = 4 * NSEC_PER_MSEC;
static NSUInteger const kSCHAudioBookPlayerNoAudioLoaded = NSUIntegerMax;

@interface SCHAudioBookPlayer ()

@property (nonatomic, retain) NSArray *audioBookReferences;
@property (nonatomic, retain) NSArray *audioInfos;  
@property (nonatomic, retain) NSArray *wordTimings;  

@property (nonatomic, retain) AVAudioPlayer *player;  
@property (nonatomic, assign) NSUInteger loadedAudioReferencesIndex;  
@property (nonatomic, assign) BOOL resumeInterruptedPlayer;
@property (nonatomic, assign) dispatch_source_t timer;

- (SCHAudioInfo *)audioInfoForPageIndex:(NSUInteger)pageIndex;
- (BOOL)prepareToPlay:(SCHAudioInfo *)audioInfoToPrepare 
           pageWordOffset:(NSUInteger)pageWordOffset;

@end

@implementation SCHAudioBookPlayer

@synthesize delegate;
@synthesize audioBookReferences;
@synthesize audioInfos;
@synthesize wordTimings;
@synthesize xpsProvider;
@synthesize player;
@synthesize loadedAudioReferencesIndex;
@synthesize resumeInterruptedPlayer;
@synthesize timer;
@dynamic playing;

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        loadedAudioReferencesIndex = kSCHAudioBookPlayerNoAudioLoaded;
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
    
    [audioBookReferences release], audioBookReferences = nil;
    [audioInfos release], audioInfos = nil;
    [wordTimings release], wordTimings = nil;
    [xpsProvider release], xpsProvider = nil;
    [player release], player = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (BOOL)prepareAudio:(NSArray *)setAudioBookReferences 
                error:(NSError **)outError wordBlock:(WordBlock)wordBlock {
    BOOL ret = NO;
    
    if (setAudioBookReferences != nil && [setAudioBookReferences count] > 0) {
        // Audiobook Reference
        self.audioBookReferences = setAudioBookReferences;

        // Audio.xml
        NSData *audioInfoData = [self.xpsProvider dataForComponentAtPath:
                                 KNFBXPSAudiobookMetadataFile];
        if (audioInfoData != nil) {
            SCHAudioInfoProcessor *audioInfoProcessor = [[SCHAudioInfoProcessor alloc] init];
            self.audioInfos = [audioInfoProcessor audioInfoFrom:audioInfoData 
                                                         error:outError];
            [audioInfoProcessor release], audioInfoProcessor = nil;
            
            // register for going into the background
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(willResignActiveNotification:)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];            

            // word timer
            dispatch_queue_t q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q_default); 
            dispatch_time_t now = dispatch_walltime(DISPATCH_TIME_NOW, 0);
            dispatch_source_set_timer(self.timer, now, kSCHAudioBookPlayerWordTimerInterval, NSEC_PER_MSEC);
            dispatch_source_set_event_handler(self.timer, ^{                
                static NSUInteger currentPosition = 0;
                static NSUInteger currentAudioInfoPosition = 0;
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
                        for (NSUInteger i = currentAudioInfoPosition; i < [self.audioInfos count]; i++) {                        
                            SCHAudioInfo *audioInfo = [self.audioInfos objectAtIndex:i];
                            SCHAudioInfo *nextAudioInfo = nil;
                            
                            if (i + 1 < [self.audioInfos count]) {
                                nextAudioInfo = [self.audioInfos objectAtIndex:i + 1];
                            }
                            
                            if (currentPosition >= audioInfo.timeIndex && 
                                (nextAudioInfo == nil ||
                                currentPosition < nextAudioInfo.timeIndex)) {
                                currentAudioInfoPosition = i;
                                    break;
                            }
                        }
                        break;
                    case NSOrderedDescending:
                        // rewind
                        if (currentPosition > 0) {
                            for (NSInteger i = currentPosition - 1; i >= 0; i--) {
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
                        for (NSInteger i = currentAudioInfoPosition; i >= 0; i--) {                        
                            SCHAudioInfo *audioInfo = [self.audioInfos objectAtIndex:i];
                            SCHAudioInfo *nextAudioInfo = nil;
                            
                            if (i + 1 < [self.audioInfos count]) {
                                nextAudioInfo = [self.audioInfos objectAtIndex:i + 1];
                            }
                            
                            if (currentPosition >= audioInfo.timeIndex && 
                                (nextAudioInfo == nil ||
                                 currentPosition < nextAudioInfo.timeIndex)) {
                                    currentAudioInfoPosition = i;
                                    break;
                                }
                        }
                        break;                                
                }  
                
                if (wordTiming != lastTriggered && [wordTiming compareTime:currentPlayTime] == NSOrderedSame) {
                    lastTriggered = wordTiming;
                    SCHAudioInfo *audioInfo = [self.audioInfos objectAtIndex:currentAudioInfoPosition];
                    wordBlock(audioInfo.pageIndex + 1, currentPosition - audioInfo.timeIndex);
                }                                                
            });            
            
            ret = YES;
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

- (BOOL)playAtLayoutPage:(NSUInteger)layoutPage pageWordOffset:(NSUInteger)pageWordOffset
{  
    BOOL ret = NO;
    
    SCHAudioInfo *audioInfo = [self audioInfoForPageIndex:(layoutPage == 0 ? 0 : layoutPage - 1)];
    if (audioInfo != nil && [self prepareToPlay:audioInfo pageWordOffset:pageWordOffset] == YES) {        
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

- (BOOL)playing
{
    return(self.player.playing);
}

#pragma mark - Private methods

- (SCHAudioInfo *)audioInfoForPageIndex:(NSUInteger)pageIndex
{    
    SCHAudioInfo *ret = nil;

    // find the files to use
    for (NSUInteger i = 0; i < [self.audioInfos count]; i++) {
        SCHAudioInfo *audioInfo = [self.audioInfos objectAtIndex:i];
        if (audioInfo.pageIndex >= pageIndex && 
            audioInfo.audioReferenceIndex < [self.audioBookReferences count]) {
            ret = audioInfo;
            break;
        }
    }
    
    return(ret);
}

- (BOOL)prepareToPlay:(SCHAudioInfo *)audioInfoToPrepare pageWordOffset:(NSUInteger)pageWordOffset
{    
    BOOL ret = NO;
    NSError *error = nil;
        
    if (audioInfoToPrepare != nil) {
        if (audioInfoToPrepare.audioReferenceIndex == self.loadedAudioReferencesIndex) {
            ret = YES;
        } else {
            NSDictionary *audioBookReference = [self.audioBookReferences objectAtIndex:audioInfoToPrepare.audioReferenceIndex];
            
            // word timing
            NSData *wordTimingData = [self.xpsProvider dataForComponentAtPath:
                                      [KNFBXPSAudiobookDirectory stringByAppendingPathComponent:
                                       [audioBookReference valueForKey:kSCHAppBookTimingFile]]];
            
            SCHWordTimingProcessor *wordTimingProcessor = [[SCHWordTimingProcessor alloc] init];
            self.wordTimings = [wordTimingProcessor startTimesFrom:wordTimingData error:&error];
            [wordTimingProcessor release], wordTimingProcessor = nil;
            
            if (self.wordTimings != nil) {
                // audio
                NSData *audioData = [self.xpsProvider dataForComponentAtPath:
                                     [KNFBXPSAudiobookDirectory stringByAppendingPathComponent:
                                      [audioBookReference valueForKey:kSCHAppBookAudioFile]]];
                
                // let the show begin
                if (audioData != nil) {
                    self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
                    if (self.player != nil) {
                        [self.player release];
                        self.player.delegate = self;
                        NSUInteger wordIndex = audioInfoToPrepare.timeIndex + pageWordOffset;                    
                        if ([self.player prepareToPlay] == YES && wordIndex < [self.wordTimings count]) {
                            SCHWordTiming *wordTiming = [self.wordTimings objectAtIndex:wordIndex];
                            self.player.currentTime = [wordTiming startTimeAsSeconds];
                            ret = YES;
                            self.loadedAudioReferencesIndex = audioInfoToPrepare.audioReferenceIndex;                            
                        }
                    }
                }
            }
        }
    }
    
    return(ret);
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
    NSUInteger nextAudioReferencesIndex = self.loadedAudioReferencesIndex + 1;
    if (nextAudioReferencesIndex < [self.audioBookReferences count]) {
        if ([self prepareToPlay:[self.audioBookReferences objectAtIndex:nextAudioReferencesIndex] 
                                 pageWordOffset:0] == YES) {        
            [self play];
        }
    } else {
        if (self.timer != NULL) {
            dispatch_suspend(self.timer);
        }
        
        if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerDidFinishPlaying:successfully:)]) {
            [(id)self.delegate audioBookPlayerDidFinishPlaying:self successfully:flag];
        }    
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
