//
//  SCHUnqueuedAudioPlayer.h
//  Scholastic
//
//  Created by Neil Gall on 28/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SCHUnqueuedAudioPlayer : NSObject <AVAudioPlayerDelegate>

+ (SCHUnqueuedAudioPlayer *)sharedAudioPlayer;

- (void)playAudioAtPath:(NSString *)path;
- (void)playAudioFromMainBundle:(NSString *)filename;
- (void)stopAll;

@end
