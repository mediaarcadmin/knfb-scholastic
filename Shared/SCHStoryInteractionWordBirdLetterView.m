//
//  SCHStoryInteractionWordBirdLetterView.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordBirdLetterView.h"

#define kLabelTag 123

@implementation SCHStoryInteractionWordBirdLetterView

+ (SCHStoryInteractionWordBirdLetterView *)letter
{
    SCHStoryInteractionWordBirdLetterView *letter = [super buttonWithType:UIButtonTypeCustom];
    [letter setBackgroundColor:[UIColor clearColor]];
    [letter setBackgroundImage:[UIImage imageNamed:@"storyinteraction-lettertile"] forState:UIControlStateNormal];
    [letter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [letter.titleLabel setTextAlignment:UITextAlignmentCenter];
    [letter.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:30]];
    return letter;
}

- (unichar)letter
{
    NSString *text = self.titleLabel.text;
    return [text length] > 0 ? [text characterAtIndex:0] : 0;
}

- (void)setLetter:(unichar)letter
{
    [self setTitle:[NSString stringWithCharacters:&letter length:1] forState:UIControlStateNormal];
}

- (void)setCorrectHighlight
{
    [self setBackgroundImage:[UIImage imageNamed:@"storyinteraction-lettertile-green"] forState:UIControlStateNormal];
}

- (void)setIncorrectHighlight
{
    [self setBackgroundImage:[UIImage imageNamed:@"storyinteraction-lettertile-red"] forState:UIControlStateNormal];
}

@end
