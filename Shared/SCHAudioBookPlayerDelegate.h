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

- (void)audioBookPlayerHighlightWordOld:(SCHAudioBookPlayer *)player
                             layoutPage:(NSUInteger)layoutPage
                         pageWordOffset:(NSUInteger)pageWordOffset;
- (void)audioBookPlayerHighlightWordNew:(SCHAudioBookPlayer *)player
                             layoutPage:(NSUInteger)layoutPage
                           audioBlockID:(NSUInteger)audioBlockID
                            audioWordID:(NSUInteger)audioWordID;
- (void)audioBookPlayerPageTurn:(SCHAudioBookPlayer *)player
               turnToLayoutPage:(NSUInteger)turnToLayoutPage;

- (void)audioBookPlayerDidFinishPlaying:(SCHAudioBookPlayer *)player successfully:(BOOL)flag;
- (void)audioBookPlayerErrorDidOccur:(SCHAudioBookPlayer *)player error:(NSError *)error;

@end
