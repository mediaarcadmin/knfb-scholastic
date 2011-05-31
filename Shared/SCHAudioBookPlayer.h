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

@class SCHXPSProvider;

typedef void (^WordBlock)(NSUInteger layoutPage, NSUInteger pageWordOffset);

static NSString * const kSCHAudioBookPlayerErrorDomain = @"AudioBookPlayerErrorDomain";
static NSInteger const kSCHAudioBookPlayerFileError = 2000;
static NSInteger const kSCHAudioBookPlayerDataError = 2001;

@interface SCHAudioBookPlayer : NSObject <AVAudioPlayerDelegate>
{
}

@property (nonatomic, assign) id<SCHAudioBookPlayerDelegate> delegate; 
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, readonly) BOOL playing;

- (BOOL)prepareAudio:(NSArray *)setAudioBookReferences 
               error:(NSError **)outError wordBlock:(WordBlock)wordBlock;
- (void)cleanAudio;
- (BOOL)play;
- (BOOL)playAtLayoutPage:(NSUInteger)layoutPage pageWordOffset:(NSUInteger)pageWordOffset;
- (void)pause;

@end
