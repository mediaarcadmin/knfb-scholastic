//
//  SCHAudioBookPlayer.h
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVAudioPlayer.h>

#import "SCHAudioBookPlayerDelegate.h"

typedef void (^WordBlock)(NSUInteger position);

static NSString * const kSCHAudioBookPlayerErrorDomain = @"AudioBookPlayerErrorDomain";
static NSInteger const kSCHAudioBookPlayerFileError = 2000;
static NSInteger const kSCHAudioBookPlayerDataError = 2001;

@interface SCHAudioBookPlayer : NSObject <AVAudioPlayerDelegate>
{
}

@property (nonatomic, assign) id<SCHAudioBookPlayerDelegate> delegate; 
@property (nonatomic, readonly) BOOL playing;

- (BOOL)prepareToPlay:(NSData *)audioData audioInfoData:(NSData *)audioInfoData 
   wordTimingFileData:(NSData *)wordTimingData 
                error:(NSError **)outError wordBlock:(WordBlock)wordBlock;
- (BOOL)play;
- (BOOL)playAtIndex:(NSUInteger)newTime;
- (void)pause;
- (void)stop;

@end
