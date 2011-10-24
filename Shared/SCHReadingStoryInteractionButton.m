//
//  SCHReadingStoryInteractionButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStoryInteractionButton.h"
#import "SCHAnimationDelegate.h"

@interface SCHReadingStoryInteractionButtonFillLayer : CALayer
@property (nonatomic, assign) float fillLevel;
@property (nonatomic, assign) CGImageRef fillImage;
@end

@implementation SCHReadingStoryInteractionButtonFillLayer

@synthesize fillLevel;
@synthesize fillImage;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"fillLevel"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)dealloc
{
    CGImageRelease(fillImage);
    [super dealloc];
}

- (void)setFillImage:(CGImageRef)newFillImage
{
    CGImageRelease(fillImage);
    fillImage = CGImageRetain(newFillImage);
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGRect bounds = self.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1, -1);

    // allow for insets
    CGRect rect = CGRectMake(0, 0.1*height, width, height*self.fillLevel*0.84);
    
    CGContextClipToRect(ctx, rect);
    CGContextDrawImage(ctx, bounds, fillImage);
}

@end

@interface SCHReadingStoryInteractionButton ()
@property (nonatomic, retain) SCHReadingStoryInteractionButtonFillLayer *fillLayer;
@end

@implementation SCHReadingStoryInteractionButton

@synthesize fillLayer;
@synthesize fillLevel;
@synthesize isYounger;

- (void)dealloc
{
    [fillLayer release];
    [super dealloc];
}

- (void)setIsYounger:(BOOL)younger
{
    isYounger = younger;
    NSString *imagePrefix = (younger ? @"young" : @"old");
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-0", imagePrefix]];
    [self setImage:backgroundImage forState:UIControlStateNormal];
    
    UIImage *fillImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-3", imagePrefix]];
    [self.fillLayer setFillImage:[fillImage CGImage]];
    self.fillLayer.bounds = (CGRect){CGPointZero, fillImage.size};
    self.fillLayer.position = CGPointMake(floorf(fillImage.size.width/2), floorf(fillImage.size.height/2));
}

- (void)setFillLevel:(float)level animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"fillLevel"];
        animation.fromValue = [NSNumber numberWithFloat:self.fillLevel];
        animation.toValue = [NSNumber numberWithFloat:level];
        animation.duration = 0.5;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
            self.fillLayer.fillLevel = fillLevel;
            [self.fillLayer removeAllAnimations];
        }];
        [self.fillLayer addAnimation:animation forKey:@"fillAnimation"];
    }
    fillLevel = level;
}

- (SCHReadingStoryInteractionButtonFillLayer *)fillLayer
{
    if (fillLayer == nil) {
        self.fillLayer = [SCHReadingStoryInteractionButtonFillLayer layer];
        self.fillLayer.fillLevel = self.fillLevel;
        [self.imageView.layer addSublayer:self.fillLayer];
    }
    return fillLayer;
}

@end
