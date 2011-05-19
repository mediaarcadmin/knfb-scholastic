//
//  SCHAudioBookPlayerDelegate.h
//  Scholastic
//
//  Created by John S. Eddie on 13/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHAudioBookPlayer;

@protocol SCHAudioBookPlayerDelegate

- (void)audioBookPlayerDidFinishPlaying:(SCHAudioBookPlayer *)player successfully:(BOOL)flag;
- (void)audioBookPlayerErrorDidOccur:(SCHAudioBookPlayer *)player error:(NSError *)error;

@end
