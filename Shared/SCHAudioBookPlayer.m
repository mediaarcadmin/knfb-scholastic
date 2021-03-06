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

// Constants
NSString * const kSCHAudioBookPlayerErrorDomain = @"AudioBookPlayerErrorDomain";
NSInteger const kSCHAudioBookPlayerFileError = 2000;
NSInteger const kSCHAudioBookPlayerDataError = 2001;

static NSTimeInterval const kSCHAudioBookPlayerMilliSecondsInASecond = 1000.0;
static NSInteger const kSCHAudioBookPlayerWordTimerInterval = 4 * NSEC_PER_MSEC;
static NSUInteger const kSCHAudioBookPlayerNoAudioLoaded = NSUIntegerMax;
static NSTimeInterval const kSCHAudioBookPlayerMinimumHighlightDelay = 0.1;

@interface SCHAudioBookPlayer ()

@property (nonatomic, retain) NSArray *audioBookReferences;
@property (nonatomic, retain) NSArray *audioInfos;  
@property (nonatomic, retain) NSArray *wordTimings;  
@property (nonatomic, assign) BOOL usingNewRTXFormat;

@property (nonatomic, retain) AVAudioPlayer *player;  
@property (nonatomic, assign) NSUInteger loadedAudioReferencesIndex;  
@property (nonatomic, assign) BOOL resumeInterruptedPlayer;
@property (nonatomic, assign) dispatch_source_t timer;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isSuspended;

- (BOOL)playWithHighlightDelay:(NSTimeInterval)highlightDelayTime;
- (NSInteger)actualWordsStartOnLayoutPageForLayoutPage:(NSUInteger)layoutPage;
- (SCHAudioInfo *)audioInfoForPageIndex:(NSUInteger)pageIndex;
- (BOOL)prepareToPlay:(SCHAudioInfo *)audioInfoToPrepare 
       pageWordOffset:(NSUInteger)pageWordOffset
    currentTimeOffset:(NSTimeInterval *)currentTimeOffset;
- (void)suspend;
- (void)pauseToResume;
- (void)resumeFromPause;

@end

@implementation SCHAudioBookPlayer

@synthesize delegate;
@synthesize audioBookReferences;
@synthesize audioInfos;
@synthesize wordTimings;
@synthesize usingNewRTXFormat;
@synthesize xpsProvider;
@synthesize player;
@synthesize loadedAudioReferencesIndex;
@synthesize resumeInterruptedPlayer;
@synthesize timer;
@synthesize isPlaying;
@synthesize isSuspended;

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        loadedAudioReferencesIndex = kSCHAudioBookPlayerNoAudioLoaded;
        resumeInterruptedPlayer = NO;
        timer = NULL;
        isPlaying = NO;
        isSuspended = NO;
        
        // register for going into the background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];            
        // register for coming out of background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];        
    }
    return self ;
}

- (void)dealloc 
{
    delegate = nil;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (timer != NULL) {
        dispatch_source_cancel(timer);
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
               error:(NSError **)outError 
{
    BOOL ret = NO;
    
    __block NSUInteger currentPosition = 0;
    __block NSUInteger currentAudioInfoPosition = 0;
    __block SCHWordTiming *lastTriggered = nil;
    __block NSUInteger pageTurnAtTime = NSUIntegerMax;
    __block NSUInteger pageTurnToLayoutPage = 1;
    __block BOOL performInitialPageCheck = YES;
    
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
            
            // word timer
            dispatch_queue_t q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q_default); 
            dispatch_time_t now = dispatch_walltime(DISPATCH_TIME_NOW, 0);
            dispatch_source_set_timer(self.timer, now, kSCHAudioBookPlayerWordTimerInterval, NSEC_PER_MSEC);
            __block SCHAudioBookPlayer *weakSelf = self;
            dispatch_source_set_cancel_handler(self.timer, ^{
                if (weakSelf.timer != NULL) {
                    dispatch_release(weakSelf.timer), weakSelf.timer = NULL;
                }
            });
            dispatch_source_set_event_handler(self.timer, ^{                
                if (weakSelf.isPlaying == YES && [weakSelf.wordTimings count] > 0) {
                    // We're using the WordTimings file use of integers for time
                    NSUInteger currentPlayTime = (NSUInteger)(weakSelf.player.currentTime * kSCHAudioBookPlayerMilliSecondsInASecond);
                    if (currentPosition < [weakSelf.wordTimings count]) {
                        SCHWordTiming *wordTiming = [weakSelf.wordTimings objectAtIndex:currentPosition];
                        
                        switch ([wordTiming compareTime:currentPlayTime]) {
                            case NSOrderedSame:
                                // nop - we got our match
                                break;
                            case NSOrderedAscending:
                                // fast forward
                                for (NSUInteger i = currentPosition + 1; i < [weakSelf.wordTimings count]; i++) {
                                    SCHWordTiming *nextWordTiming = [weakSelf.wordTimings objectAtIndex:i];
                                    NSComparisonResult result = [nextWordTiming compareTime:currentPlayTime];
                                    if (result == NSOrderedSame) {
                                        currentPosition = i;
                                        wordTiming = nextWordTiming;
                                        break;
                                    } else if (result == NSOrderedDescending) {
                                        break;
                                    }
                                }
                                for (NSUInteger i = currentAudioInfoPosition; i < [weakSelf.audioInfos count]; i++) {
                                    SCHAudioInfo *audioInfo = [weakSelf.audioInfos objectAtIndex:i];
                                    SCHAudioInfo *nextAudioInfo = nil;
                                    
                                    if (i + 1 < [weakSelf.audioInfos count]) {
                                        nextAudioInfo = [weakSelf.audioInfos objectAtIndex:i + 1];
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
                                        SCHWordTiming *nextWordTiming = [weakSelf.wordTimings objectAtIndex:i];
                                        NSComparisonResult result = [nextWordTiming compareTime:currentPlayTime];                                    
                                        if (result == NSOrderedSame) {
                                            currentPosition = i;
                                            wordTiming = nextWordTiming;
                                            break;
                                        } else if (result == NSOrderedAscending) {
                                            break;
                                        }
                                    }
                                }
                                for (NSInteger i = currentAudioInfoPosition; i >= 0; i--) {                        
                                    SCHAudioInfo *audioInfo = [weakSelf.audioInfos objectAtIndex:i];
                                    SCHAudioInfo *nextAudioInfo = nil;
                                    
                                    if (i + 1 < [weakSelf.audioInfos count]) {
                                        nextAudioInfo = [weakSelf.audioInfos objectAtIndex:i + 1];
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

                        // on initial statup check if we are playing ahead of
                        // the current word and trigger a page turn if the next
                        // word is on a different page
                        if (performInitialPageCheck == YES) {
                            performInitialPageCheck = NO;
                                                        
                            if (currentPlayTime > wordTiming.endTime &&
                                currentPosition + 1 < [weakSelf.wordTimings count]) {
                                SCHWordTiming *nextWordTiming = [weakSelf.wordTimings objectAtIndex:currentPosition + 1];
                                if (wordTiming.pageIndex != nextWordTiming.pageIndex) {
                                    pageTurnAtTime = wordTiming.endTime;
                                    pageTurnToLayoutPage = nextWordTiming.pageIndex + 1;
                                }
                            }
                        }
                        
                        if ((pageTurnAtTime != NSUIntegerMax) && (currentPlayTime >= pageTurnAtTime)) {
                            //NSLog(@"executing page turn for time %d at currentPlayTime %d", pageTurnAtTime, currentPlayTime);
                            if ([(id)weakSelf.delegate conformsToProtocol:@protocol(SCHAudioBookPlayerDelegate)] == YES) {
                                [weakSelf.delegate audioBookPlayerPageTurn:weakSelf
                                                      turnToLayoutPage:pageTurnToLayoutPage];
                            }
                            pageTurnAtTime = NSUIntegerMax;
                        }
                        
                        if (wordTiming != lastTriggered && [wordTiming compareTime:currentPlayTime] == NSOrderedSame) {
                            lastTriggered = wordTiming;
                            if (weakSelf.usingNewRTXFormat == YES) {
                                //NSLog(@"wordTiming: %d currentPlayTime: %d", wordTiming.startTime, currentPlayTime);
                                if ([(id)weakSelf.delegate conformsToProtocol:@protocol(SCHAudioBookPlayerDelegate)] == YES) {
                                    [weakSelf.delegate audioBookPlayerHighlightWordNew:weakSelf
                                                                        layoutPage:wordTiming.pageIndex + 1
                                                                      audioBlockID:wordTiming.blockID
                                                                       audioWordID:wordTiming.wordID];
                                }
                                
                                pageTurnAtTime = NSUIntegerMax; 
                                if (currentPosition + 1 < [weakSelf.wordTimings count]) {
                                    SCHWordTiming *nextWordTiming = [weakSelf.wordTimings objectAtIndex:currentPosition + 1];
                                    if (wordTiming.pageIndex != nextWordTiming.pageIndex) {
                                        pageTurnAtTime = wordTiming.endTime;
                                        pageTurnToLayoutPage = nextWordTiming.pageIndex + 1;                                
                                    }
                                }                                                    
                            } else {
                                SCHAudioInfo *audioInfo = [weakSelf.audioInfos objectAtIndex:currentAudioInfoPosition];
                                if ([(id)weakSelf.delegate conformsToProtocol:@protocol(SCHAudioBookPlayerDelegate)] == YES) {
                                    [weakSelf.delegate audioBookPlayerHighlightWordOld:weakSelf
                                                                        layoutPage:audioInfo.pageIndex + 1
                                                                    pageWordOffset:currentPosition - audioInfo.timeIndex];
                                }
                                
                                pageTurnAtTime = NSUIntegerMax; 
                                if (currentAudioInfoPosition + 1 < [weakSelf.audioInfos count]) {
                                    SCHAudioInfo *nextAudioInfo = [weakSelf.audioInfos objectAtIndex:currentAudioInfoPosition + 1];
                                    if (currentPosition == nextAudioInfo.timeIndex - 1) {
                                        pageTurnAtTime = wordTiming.endTime;
                                        pageTurnToLayoutPage = nextAudioInfo.pageIndex + 1;
                                    }
                                }                            
                            }
                        }
                    }
                }                                                
            });            
            
            ret = YES;
        }
    }
    
    return ret;
}

- (void)cleanAudio
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.timer != NULL) {
        dispatch_source_cancel(self.timer);
    }
    
    self.player = nil;
    self.audioBookReferences = nil;
    self.audioInfos = nil;
    self.wordTimings = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;    
    
    self.loadedAudioReferencesIndex = kSCHAudioBookPlayerNoAudioLoaded;
}

- (BOOL)play
{
    return [self playWithHighlightDelay:0.0];
}

- (BOOL)playWithHighlightDelay:(NSTimeInterval)highlightDelayTime
{
    //NSLog(@"SCHAudioBookPlayer play with current time: %d", (NSUInteger)(self.player.currentTime * kSCHAudioBookPlayerMilliSecondsInASecond));    

    BOOL ret = NO;
    
    ret = [self.player play];
    if (ret == NO) {
        self.isPlaying = NO;
    } else {
        SCHAudioBookPlayer *weakSelf = self;
        dispatch_block_t block = ^{
            weakSelf.isPlaying = YES;
            if (weakSelf.timer != NULL) {
                [UIApplication sharedApplication].idleTimerDisabled = YES;        
                dispatch_resume(weakSelf.timer);
                weakSelf.isSuspended = NO;
            }        
        };
        
        if (highlightDelayTime > 0.0) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, highlightDelayTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), block);        
        } else {
            block();
        }
    }

    return ret;
}

- (BOOL)playAtLayoutPage:(NSUInteger)layoutPage
          pageWordOffset:(NSUInteger)pageWordOffset
priorToPlayingAudioBlock:(SCHAudioBookPlayerPriorToPlayingAudioBlock)priorToPlayingAudioBlock
{
    NSParameterAssert(priorToPlayingAudioBlock);

    //NSLog(@"SCHAudioBookPlayer playAtLayoutPage");  
    BOOL ret = NO;
    NSTimeInterval currentTimeOffset = 0.0;
    NSUInteger layoutPageIndex = (layoutPage == 0 ? 0 : layoutPage - 1);
    
    SCHAudioInfo *audioInfo = [self audioInfoForPageIndex:layoutPageIndex];
    
    if (audioInfo != nil && [self prepareToPlay:audioInfo
                                 pageWordOffset:pageWordOffset
                              currentTimeOffset:&currentTimeOffset] == YES) {
        NSInteger actualWordsStartOnLayoutPage = [self actualWordsStartOnLayoutPageForLayoutPage:layoutPageIndex];
        // assume we are on the correct layoutPage if we couldnt find one
        if (actualWordsStartOnLayoutPage == NSNotFound) {
            actualWordsStartOnLayoutPage = layoutPage;
        }
        ret = YES;
        priorToPlayingAudioBlock(actualWordsStartOnLayoutPage, ^{
            return [self playWithHighlightDelay:currentTimeOffset];
        });
    }

    return ret;
}

// This will always return NSNotFound if word timings has not been populated
- (NSInteger)actualWordsStartOnLayoutPageForLayoutPage:(NSUInteger)layoutPageIndex
{
    NSInteger ret = NSNotFound;

    NSAssert(self.wordTimings != nil, @"WordTimings should be populated");

    for (SCHWordTiming *wordTiming in self.wordTimings) {
        if (wordTiming.pageIndex >= layoutPageIndex) {
            // we got our match
            ret = wordTiming.pageIndex + 1;
            break;
        }
    }

    return ret;
}

- (void)pause
{
    //NSLog(@"SCHAudioBookPlayer pause with current time: %d", (NSUInteger)(self.player.currentTime * kSCHAudioBookPlayerMilliSecondsInASecond));    
    if (self.isPlaying == YES) {
        [self suspend];
        [self.player pause];
        self.isPlaying = NO;        
    }
    self.resumeInterruptedPlayer = NO;
}

#pragma mark - Private methods

- (SCHAudioInfo *)audioInfoForPageIndex:(NSUInteger)pageIndex
{    
    SCHAudioInfo *ret = nil;

    // find the files to use
    for (SCHAudioInfo *audioInfo in self.audioInfos) {
        if (audioInfo.pageIndex >= pageIndex && 
            audioInfo.audioReferenceIndex < [self.audioBookReferences count]) {
            ret = audioInfo;
            break;
        }
    }
    
    return ret;
}

- (BOOL)prepareToPlay:(SCHAudioInfo *)audioInfoToPrepare 
       pageWordOffset:(NSUInteger)pageWordOffset
    currentTimeOffset:(NSTimeInterval *)currentTimeOffset
{    
    BOOL ret = NO;
    NSError *error = nil;
        
    if (audioInfoToPrepare != nil) {
        if (audioInfoToPrepare.audioReferenceIndex == self.loadedAudioReferencesIndex) {
            ret = YES;
        } else if (audioInfoToPrepare.audioReferenceIndex < [self.audioBookReferences count]) {
            NSDictionary *audioBookReference = [self.audioBookReferences objectAtIndex:audioInfoToPrepare.audioReferenceIndex];
            
            // word timing
            NSData *wordTimingData = [self.xpsProvider dataForComponentAtPath:
                                      [KNFBXPSAudiobookDirectory stringByAppendingPathComponent:
                                       [audioBookReference valueForKey:kSCHAppBookTimingFile]]];
            
            SCHWordTimingProcessor *wordTimingProcessor = [[SCHWordTimingProcessor alloc] init];
            self.wordTimings = [wordTimingProcessor startTimesFrom:wordTimingData error:&error];
            self.usingNewRTXFormat = wordTimingProcessor.newRTXFormat;

            BOOL valid = [wordTimingProcessor validateWordTimings:self.wordTimings 
                                                        pageIndex:audioInfoToPrepare.pageIndex
                                                        timeIndex:audioInfoToPrepare.timeIndex
                                                       timeOffset:audioInfoToPrepare.timeOffset];  
            
            // Scholastic request that we still plow on and highlight words randomly, even if there is a mismatch
            if (!valid) {
                NSLog(@"Warning: wordTimings are not valid but continuing with highlighting anyway");
                valid = YES;
            }
            
            [wordTimingProcessor release], wordTimingProcessor = nil;
            
            if (self.wordTimings != nil && valid) {
                // audio
                NSData *audioData = [self.xpsProvider dataForComponentAtPath:
                                     [KNFBXPSAudiobookDirectory stringByAppendingPathComponent:
                                      [audioBookReference valueForKey:kSCHAppBookAudioFile]]];
                
                // let the show begin
                if (audioData != nil) {
                    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
                    self.player = newPlayer;
                    [newPlayer release];
                    if (self.player != nil) {
                        self.player.delegate = self;
                        if ([self.player prepareToPlay] == YES) {
                            ret = YES;
                            self.loadedAudioReferencesIndex = audioInfoToPrepare.audioReferenceIndex;                            
                        }
                    }
                }
            }
        }
        NSUInteger wordIndex = audioInfoToPrepare.timeIndex + pageWordOffset;                    
        if (wordIndex < [self.wordTimings count]) {
            SCHWordTiming *wordTiming = [self.wordTimings objectAtIndex:wordIndex];
            NSTimeInterval startTime = [wordTiming startTimeAsSeconds];
            self.player.currentTime = startTime;       
            
            // Setting self.player.currentTime will often give you a time in the
            // past by a small amount, we delay resuming highlighting block so 
            // we don't end up with a backward page flip
            if (self.player.currentTime < startTime) {
                *currentTimeOffset = MAX(kSCHAudioBookPlayerMinimumHighlightDelay, startTime - self.player.currentTime);

            }
        }
    }
    
    return ret;
}

- (void)suspend
{
    if (self.timer != NULL && self.isSuspended == NO) {
        dispatch_suspend(self.timer);
        self.isSuspended = YES;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;    
}

- (void)pauseToResume
{
    if (self.isPlaying == YES) {
        [self pause];
        self.resumeInterruptedPlayer = YES;
    }    
}

- (void)resumeFromPause
{
    if (self.resumeInterruptedPlayer == YES) {
        self.resumeInterruptedPlayer = NO;
        [self play];
    }    
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    NSLog(@"SCHAudioBookPlayer willResignActiveNotification"); 
    [self pauseToResume];
}

- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    NSLog(@"SCHAudioBookPlayer didBecomeActiveNotification");    
    [self resumeFromPause];
}

#pragma mark - AVAudioPlayer Delegate methods

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"SCHAudioBookPlayer audioPlayerBeginInterruption");
    [self pauseToResume];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"SCHAudioBookPlayer audioPlayerEndInterruption");    
    [self resumeFromPause];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"SCHAudioBookPlayer audioPlayerDidFinishPlaying");
    NSUInteger nextAudioReferencesIndex = self.loadedAudioReferencesIndex + 1;
    NSTimeInterval currentTimeOffset = 0.0;
    
    if (nextAudioReferencesIndex < [self.audioBookReferences count]) {
        if ([self prepareToPlay:[self.audioBookReferences objectAtIndex:nextAudioReferencesIndex] 
                                 pageWordOffset:0 
              currentTimeOffset:&currentTimeOffset] == YES) {        
            [self playWithHighlightDelay:currentTimeOffset];
        }
    } else {
        [self suspend];
        
        if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerDidFinishPlaying:successfully:)]) {
            [(id)self.delegate audioBookPlayerDidFinishPlaying:self successfully:flag];
        }    
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"SCHAudioBookPlayer audioPlayerDecodeErrorDidOccur");    
    [self suspend];
    
    if([(id)self.delegate respondsToSelector:@selector(audioBookPlayerErrorDidOccur:error:)]) {
        [(id)self.delegate audioBookPlayerErrorDidOccur:self error:error];
    }     
}

@end
