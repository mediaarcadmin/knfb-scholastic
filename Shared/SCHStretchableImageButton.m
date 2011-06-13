//
//  SCHStretchableImageButton.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStretchableImageButton.h"


@implementation SCHStretchableImageButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        // reset the images for each control state to stretch them
        static const UIControlState states[] = {
            UIControlStateNormal,
            UIControlStateHighlighted,
            UIControlStateDisabled,
            UIControlStateSelected
        };
        for (int i = 0; i < sizeof(states)/sizeof(states[0]); ++i) {
            [self setImage:[self imageForState:states[i]] forState:states[i]];
            [self setBackgroundImage:[self backgroundImageForState:states[i]] forState:states[i]];
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [super setImage:stretchable forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [super setBackgroundImage:stretchable forState:state];
}

@end
