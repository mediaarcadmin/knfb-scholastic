//
//  SCHStoryInteractionSequencing.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionSequencing : SCHStoryInteraction {}

- (NSInteger)numberOfImages;

// XPSProvider-relative path
- (NSString *)audioPathForQuestion;

// XPSProvider-relative path
- (NSString *)audioPathForCorrectAnswer;

// XPSProvider-relative path for image
- (NSString *)imagePathForIndex:(NSInteger)index;

// XPSProvider-relative path for audio
- (NSString *)audioPathForCorrectAnswerAtIndex:(NSInteger)index;

@end
