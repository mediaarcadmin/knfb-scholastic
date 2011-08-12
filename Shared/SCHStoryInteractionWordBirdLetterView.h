//
//  SCHStoryInteractionWordBirdLetterView.h
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHStoryInteractionWordBirdLetterView : UIButton {}

@property (nonatomic, assign) unichar letter;

+ (SCHStoryInteractionWordBirdLetterView *)letter;

- (void)setCorrectHighlight;
- (void)setIncorrectHighlight;

@end
