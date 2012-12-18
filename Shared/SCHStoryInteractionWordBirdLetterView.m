//
//  SCHStoryInteractionWordBirdLetterView.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordBirdLetterView.h"

@implementation SCHStoryInteractionWordBirdLetterView

+ (SCHStoryInteractionWordBirdLetterView *)letter
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    SCHStoryInteractionWordBirdLetterView *letter = [super buttonWithType:UIButtonTypeCustom];
    [letter setBackgroundColor:[UIColor clearColor]];
    [letter setBackgroundImage:[[UIImage imageNamed:@"storyinteraction-lettertile"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    [letter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [letter.titleLabel setTextAlignment:UITextAlignmentCenter];
    [letter.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:iPad?30:22]];
    [letter.titleLabel setAdjustsFontSizeToFitWidth:NO];
    // to avoid rounding issues that draw the letters slightly left of center
    letter.titleEdgeInsets = UIEdgeInsetsMake(0, ([UIScreen mainScreen].scale > 1.0 ? 0.5 : 1), 0, 0);
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
    [self setBackgroundImage:[[UIImage imageNamed:@"storyinteraction-lettertile-green"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
}

- (void)setIncorrectHighlight
{
    [self setBackgroundImage:[[UIImage imageNamed:@"storyinteraction-lettertile-red"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
}

- (void)removeHighlight
{
    [self setBackgroundImage:[[UIImage imageNamed:@"storyinteraction-lettertile"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
}

@end
