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

// Constants
extern NSString * const kSCHAudioBookPlayerErrorDomain;
extern NSInteger const kSCHAudioBookPlayerFileError;
extern NSInteger const kSCHAudioBookPlayerDataError;

@interface SCHAudioBookPlayer : NSObject <AVAudioPlayerDelegate>
{
}

@property (nonatomic, assign) id<SCHAudioBookPlayerDelegate> delegate; 
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, readonly) BOOL isPlaying;

- (BOOL)prepareAudio:(NSArray *)setAudioBookReferences 
               error:(NSError **)outError;
- (void)cleanAudio;
- (BOOL)play;
- (BOOL)playAtLayoutPage:(NSUInteger)layoutPage 
          pageWordOffset:(NSUInteger)pageWordOffset;
- (void)pause;

@end
