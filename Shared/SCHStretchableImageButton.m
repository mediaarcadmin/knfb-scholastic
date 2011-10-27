//
//  SCHStretchableImageButton.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStretchableImageButton.h"

@interface SCHStretchableImageButton ()

@property (nonatomic, retain) NSMutableDictionary *unstretchedImages;

- (UIImage *)stretchImageForControlState:(UIControlState)controlState;
- (void)stretchAll;

@end

@implementation SCHStretchableImageButton

@synthesize customLeftCap;
@synthesize customTopCap;
@synthesize unstretchedImages;

- (void)dealloc
{
    [unstretchedImages release], unstretchedImages = nil;
    [super dealloc];
}

- (NSInteger)leftCapForImage:(UIImage *)image
{
    if (customLeftCap > 0) {
        return customLeftCap;
    }
    if (image.size.width >= CGRectGetWidth(self.bounds)) {
        return 0;
    }
    return image.size.width/2-1;
}

- (NSInteger)topCapForImage:(UIImage *)image
{
    if (customTopCap > 0) {
        return customTopCap;
    }
    if (image.size.height >= CGRectGetHeight(self.bounds)) {
        return 0;
    }
    return image.size.height/2-1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.unstretchedImages = [NSMutableDictionary dictionary];
        
        UIImage *unstretchedBackgroundImage = [self backgroundImageForState:UIControlStateNormal];
        if (unstretchedBackgroundImage) {
            [self.unstretchedImages setObject:unstretchedBackgroundImage forKey:[NSNumber numberWithInteger:UIControlStateNormal]];
            UIImage *stretchedNormalBackground = [self stretchImageForControlState:UIControlStateNormal];
            
            static const UIControlState states[] = {
                UIControlStateHighlighted,
                UIControlStateDisabled,
                UIControlStateSelected
            };
            static const size_t stateCount = sizeof(states)/sizeof(states[0]);
            
            for (int i = 0; i < stateCount; ++i) {
                UIImage *image = [self backgroundImageForState:states[i]];
                if (image != nil && [image CGImage] != [stretchedNormalBackground CGImage]) {
                    [self.unstretchedImages setObject:image forKey:[NSNumber numberWithInteger:states[i]]];
                    [self stretchImageForControlState:states[i]];
                }
            }
        }
    }
    return self;
}

- (void)setCustomTopCap:(NSInteger)cap
{
    customTopCap = cap;
    [self stretchAll];
}

- (void)setCustomLeftCap:(NSInteger)cap
{
    customLeftCap = cap;
    [self stretchAll];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    UIImage *stretchable = [image stretchableImageWithLeftCapWidth:[self leftCapForImage:image]
                                                      topCapHeight:[self topCapForImage:image]];
    [super setImage:stretchable forState:state];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [self.unstretchedImages setObject:image forKey:[NSNumber numberWithInteger:state]];
    [self stretchImageForControlState:state];
}

- (UIImage *)stretchImageForControlState:(UIControlState)controlState
{
    UIImage *unstretched = [self.unstretchedImages objectForKey:[NSNumber numberWithInteger:controlState]];
    if (!unstretched) {
        return nil;
    }
    UIImage *stretchable = [unstretched stretchableImageWithLeftCapWidth:[self leftCapForImage:unstretched]
                                                            topCapHeight:[self topCapForImage:unstretched]];
    [super setBackgroundImage:stretchable forState:controlState];
    return stretchable;
}

- (void)stretchAll
{
    for (NSNumber *controlState in [self.unstretchedImages allKeys]) {
        [self stretchImageForControlState:[controlState integerValue]];
    }
}

@end
