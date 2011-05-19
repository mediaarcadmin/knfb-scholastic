//
//  SCHAudioBookPlayer.h
//  Scholastic
//
//  Created by John S. Eddie on 11/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHAudioBookPlayerDelegate.h"

@interface SCHAudioBookPlayer : NSObject 
{
}

@property (nonatomic, assign) id<SCHAudioBookPlayerDelegate> delegate; 
@property (nonatomic, readonly) BOOL playing;

- (id)initWithAudioFile:(NSURL *)aAudioFile wordTimingFilePath:(NSString *)aWordTimingFilePath;
- (BOOL)playAtTime:(NSUInteger)milliseconds;
- (BOOL)play;
- (void)pause;

@end
