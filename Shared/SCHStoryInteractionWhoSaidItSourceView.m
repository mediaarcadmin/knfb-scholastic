//
//  SCHStoryInteractionWhoSaidItSourceView.m
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWhoSaidItSourceView.h"

#define kTitleViewTag 572

@implementation SCHStoryInteractionWhoSaidItSourceView

- (NSString *)title
{
    UILabel *label = (UILabel *)[self viewWithTag:kTitleViewTag];
    return label.text;
}

- (void)setTitle:(NSString *)title
{
    [[self viewWithTag:kTitleViewTag] removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = kTitleViewTag;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = title;
    label.font = [UIFont systemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20 : 14];
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    [label release];
}

- (void)layoutSubviews
{
    [self viewWithTag:kTitleViewTag].frame = CGRectMake(4, 12, CGRectGetWidth(self.bounds)-8, CGRectGetHeight(self.bounds)-12);
    [super layoutSubviews];
}

@end
