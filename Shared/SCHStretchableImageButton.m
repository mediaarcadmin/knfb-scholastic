//
//  SCHStretchableImageButton.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStretchableImageButton.h"

#define kLeftCap 10
#define kTopCap 0

@implementation SCHStretchableImageButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        UIImage *normalBackgroundImage = [self backgroundImageForState:UIControlStateNormal];
        if (normalBackgroundImage) {
            UIImage *stretchable = [normalBackgroundImage stretchableImageWithLeftCapWidth:kLeftCap topCapHeight:kTopCap];
            [self setBackgroundImage:stretchable forState:UIControlStateNormal];
            
            static const UIControlState states[] = {
                UIControlStateHighlighted,
                UIControlStateDisabled,
                UIControlStateSelected
            };
            for (int i = 0; i < sizeof(states)/sizeof(states[0]); ++i) {
                UIImage *image = [self backgroundImageForState:states[i]];
                if (image != nil && image != stretchable) {
                    [self setBackgroundImage:[image stretchableImageWithLeftCapWidth:kLeftCap topCapHeight:kTopCap] forState:states[i]];
                }
            }
        }
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)normalBackgroundImage forState:(UIControlState)state
{    
    if (normalBackgroundImage) {
        UIImage *stretchable = [normalBackgroundImage stretchableImageWithLeftCapWidth:kLeftCap topCapHeight:kTopCap];
        [super setBackgroundImage:stretchable forState:state];
    }
    
}

@end
