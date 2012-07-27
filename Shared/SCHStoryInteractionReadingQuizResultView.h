//
//  SCHStoryInteractionReadingQuizResultView.h
//  Scholastic
//
//  Created by Gordon Christie on 27/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHStoryInteractionReadingQuizResultView : UIView

- (void)setCorrectAnswer:(NSString *)answer;
- (void)setWrongAnswer:(NSString *)answer;
- (void)setQuestion:(NSString *)question;

@end
