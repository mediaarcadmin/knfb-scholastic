//
//  SCHAnimatedLayer.m
//  Scholastic
//
//  Created by Neil Gall on 17/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAnimatedLayer.h"

@implementation SCHAnimatedLayer

@synthesize frameSize;
@synthesize frameIndex;

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
    CGImageRef image = (CGImageRef)self.contents;
    NSInteger cols = CGImageGetWidth(image)/self.frameSize.width;
    NSInteger rows = CGImageGetHeight(image)/self.frameSize.height;
    return rows*cols;
}

- (void)display
{
    size_t width = CGImageGetWidth((CGImageRef)self.contents);
    size_t height = CGImageGetHeight((CGImageRef)self.contents);
    CGSize size = [(SCHAnimatedLayer *)self.modelLayer frameSize];
    NSInteger framesPerRow = width/size.width;
    NSInteger index = [(SCHAnimatedLayer *)self.presentationLayer frameIndex];
    NSInteger row = index/framesPerRow;
    NSInteger col = index%framesPerRow;
    self.contentsRect = CGRectMake((size.width*col)/width, (size.height*row)/height, size.width/width, size.height/height);
    
    NSLog(@"frame index %d  (%d)", index, self.frameIndex);
}

- (void)animateAllFramesWithDuration:(CFTimeInterval)duration
                            delegate:(id)delegate
{
    NSInteger lastFrame = self.numberOfFrames-1;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"frameIndex"];
    anim.fromValue = [NSNumber numberWithInteger:0];
    anim.toValue = [NSNumber numberWithInteger:lastFrame];
    anim.duration = duration;
    anim.delegate = delegate;
    [self addAnimation:anim forKey:@"animation"];
    
    self.frameIndex = lastFrame;
    [self setNeedsDisplay];
}

@end
