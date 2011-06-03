//
//  SCHStoryInteractionDraggableView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableView.h"

#define kTitleViewTag 572

@implementation SCHStoryInteractionDraggableView

- (NSString *)title
{
    UILabel *label = (UILabel *)[self viewWithTag:kTitleViewTag];
    return label.text;
}

- (void)setTitle:(NSString *)title
{
    [[self viewWithTag:kTitleViewTag] removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.tag = kTitleViewTag;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = title;
    [self addSubview:label];
    [label release];
}

- (void)layoutSubviews
{
    [self viewWithTag:kTitleViewTag].frame = self.bounds;
    [super layoutSubviews];
}

- (SCHStoryInteractionDraggableTargetView *)target
{
    return nil;
}

@end
