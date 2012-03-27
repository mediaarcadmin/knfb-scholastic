//
//  SCHBookShelfMenuPopoverBackgroundView.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfMenuPopoverBackgroundView.h"

@implementation SCHBookShelfMenuPopoverBackgroundView

#pragma mark - UIPopoverBackgroundView

+ (CGFloat)arrowBase
{
    return 26.0f;
}

+ (CGFloat)arrowHeight
{
    return 16.0f;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(12.0f, 6.0f, 8.0f, 7.0f);
}

- (void)setArrowDirection:(UIPopoverArrowDirection)direction
{
    // must be overridden
}

- (UIPopoverArrowDirection)arrowDirection
{
    return UIPopoverArrowDirectionUp;
}

- (void)setArrowOffset:(CGFloat)offset
{
    // must be overridden
}

- (CGFloat)arrowOffset
{
    return 2.0f;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
    UIEdgeInsets popoverInsets = UIEdgeInsetsMake(37.0f, 16.0f, 16.0f, 34.0f);
    UIImage *popover = [[UIImage imageNamed:@"popover_stretchable.png"] resizableImageWithCapInsets:popoverInsets];
    [popover drawInRect:rect];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setBackgroundColor:[UIColor clearColor]];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

@end