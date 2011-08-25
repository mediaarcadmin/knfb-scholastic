//
//  SCHAnimatedLayer.m
//  Scholastic
//
//  Created by Neil Gall on 17/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAnimatedLayer.h"

#define kPlayAnimationKey @"playAnimation"

@implementation SCHAnimatedLayer

@synthesize frameSize;
@synthesize frameIndex;
@synthesize numberOfFrames;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"frameIndex"] || [key isEqualToString:@"frameSize"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

+ (id<CAAction>)defaultActionForKey:(NSString *)event
{
    if ([event isEqualToString:@"contentsRect"]) {
        return (id<CAAction>)[NSNull null];
    }
    return [super defaultActionForKey:event];
}

- (NSInteger)numberOfFrames
{
    if (numberOfFrames == 0) {
        // default to the full number of frames in the image
        CGImageRef image = (CGImageRef)self.contents;
        NSInteger cols = CGImageGetWidth(image)/self.frameSize.width;
        NSInteger rows = CGImageGetHeight(image)/self.frameSize.height;
        numberOfFrames = rows*cols;
    }
    return numberOfFrames;
}

- (void)display
{
    size_t width = CGImageGetWidth((CGImageRef)self.contents);
    size_t height = CGImageGetHeight((CGImageRef)self.contents);
    CGSize size = [(SCHAnimatedLayer *)self.modelLayer frameSize];
    if (width == 0 || height == 0 || size.width == 0) {
        return;
    }
    
    NSInteger framesPerRow = width/size.width;
    NSInteger index = [self animationForKey:kPlayAnimationKey] ? [(SCHAnimatedLayer *)self.presentationLayer frameIndex] : self.frameIndex;
    NSInteger row = index/framesPerRow;
    NSInteger col = index%framesPerRow;
    self.contentsRect = CGRectMake((size.width*col)/width, (size.height*row)/height, size.width/width, size.height/height);
}

- (void)animateAllFramesWithDuration:(CFTimeInterval)duration
                          frameOrder:(NSArray*)frameOrder
                         autoreverse:(BOOL)autoreverse
                         repeatCount:(NSInteger)repeats
                            delegate:(id)delegate
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"frameIndex"];
    
    NSArray *frames = frameOrder;
    
    if (!frames) {
        NSMutableArray *keyFrames = [NSMutableArray array];
        
        for (int i = 0; i < self.numberOfFrames; i++) {
            [keyFrames addObject:[NSNumber numberWithInteger:i]];
        }
        
        frames = keyFrames;
    }
    
    anim.values = frames;
    anim.duration = duration;
    anim.calculationMode = kCAAnimationDiscrete;
    anim.repeatCount = repeats;
    anim.autoreverses = autoreverse;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.fillMode = kCAFillModeForwards;
    anim.delegate = delegate;
    [self addAnimation:anim forKey:kPlayAnimationKey];
}

@end
