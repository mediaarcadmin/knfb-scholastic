//
//  SCHStretchableImageButton.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStretchableImageButton.h"

@implementation SCHStretchableImageButton

- (NSInteger)leftCapForImage:(UIImage *)image
{
    if (image.size.width >= CGRectGetWidth(self.bounds)) {
        return 0;
    }
    return image.size.width/2-1;
}

- (NSInteger)topCapForImage:(UIImage *)image
{
    if (image.size.height >= CGRectGetHeight(self.bounds)) {
        return 0;
    }
    return image.size.height/2-1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        UIImage *normalBackgroundImage = [self backgroundImageForState:UIControlStateNormal];
        if (normalBackgroundImage) {
            UIImage *stretchable = [normalBackgroundImage stretchableImageWithLeftCapWidth:[self leftCapForImage:normalBackgroundImage]
                                                                              topCapHeight:[self topCapForImage:normalBackgroundImage]];
            [self setBackgroundImage:stretchable forState:UIControlStateNormal];
            
            static const UIControlState states[] = {
                UIControlStateHighlighted,
                UIControlStateDisabled,
                UIControlStateSelected
            };
            for (int i = 0; i < sizeof(states)/sizeof(states[0]); ++i) {
                UIImage *image = [self backgroundImageForState:states[i]];
                if (image != nil && [image CGImage] != [stretchable CGImage]) {
                    [self setBackgroundImage:[image stretchableImageWithLeftCapWidth:[self leftCapForImage:image]
                                                                        topCapHeight:[self topCapForImage:image]]
                                    forState:states[i]];
                }
            }
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:[self leftCapForImage:image]
                                                      topCapHeight:[self topCapForImage:image]];
    [super setImage:stretchable forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:[self leftCapForImage:image]
                                                      topCapHeight:[self topCapForImage:image]];
    [super setBackgroundImage:stretchable forState:state];
}


@end
