//
//  SCHStretchableImageButton.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStretchableImageButton.h"

@implementation SCHStretchableImageButton

static NSInteger leftCapForImage(UIImage *image)
{
    return image.size.width/2-1;
}

static NSInteger topCapForImage(UIImage *image)
{
    return image.size.height/2-1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        UIImage *normalBackgroundImage = [self backgroundImageForState:UIControlStateNormal];
        if (normalBackgroundImage) {
            UIImage *stretchable = [normalBackgroundImage stretchableImageWithLeftCapWidth:leftCapForImage(normalBackgroundImage)
                                                                              topCapHeight:topCapForImage(normalBackgroundImage)];
            [self setBackgroundImage:stretchable forState:UIControlStateNormal];
            
            static const UIControlState states[] = {
                UIControlStateHighlighted,
                UIControlStateDisabled,
                UIControlStateSelected
            };
            for (int i = 0; i < sizeof(states)/sizeof(states[0]); ++i) {
                UIImage *image = [self backgroundImageForState:states[i]];
                if (image != nil && [image CGImage] != [stretchable CGImage]) {
                    [self setBackgroundImage:[image stretchableImageWithLeftCapWidth:leftCapForImage(image)
                                                                        topCapHeight:topCapForImage(image)]
                                    forState:states[i]];
                }
            }
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:leftCapForImage(image) topCapHeight:topCapForImage(image)];
    [super setImage:stretchable forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:leftCapForImage(image) topCapHeight:topCapForImage(image)];
    [super setBackgroundImage:stretchable forState:state];
}


@end
