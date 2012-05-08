//
//  SCHReadingStoryInteractionButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStoryInteractionButton.h"
#import "SCHAnimationDelegate.h"

static const UIEdgeInsets kSCHReadingStoryInteractionButtonFillInsetYounger = { 16, 6, 16, 0 };
static const UIEdgeInsets kSCHReadingStoryInteractionButtonFillInsetOlder =  { 8, 4, 12, 0 };

static const UIEdgeInsets kSCHReadingStoryInteractionButtonFillInsetYounger_iPhone = { 4, 6, 4, 0 };
static const UIEdgeInsets kSCHReadingStoryInteractionButtonFillInsetOlder_iPhone =  { 6, 4, 0, 0 };

@interface SCHReadingStoryInteractionButtonFillLayer : CALayer
@property (nonatomic, assign) float fillLevel;
@property (nonatomic, assign) CGImageRef fillImage;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) UIEdgeInsets fillInset;
@end

@implementation SCHReadingStoryInteractionButtonFillLayer

@synthesize fillLevel;
@synthesize fillImage;
@synthesize highlighted;
@synthesize fillInset;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"fillLevel"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (id)initWithLayer:(SCHReadingStoryInteractionButtonFillLayer *)layer
{
    if ((self = [super initWithLayer:layer])) {
        // Don't make a copy of the CGImage - just reference the model's copy when drawing
        self.fillLevel = layer.fillLevel;
        self.highlighted = layer.highlighted;
        self.fillInset = layer.fillInset;
    }
    
    return self;
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

- (void)setHighlighted:(BOOL)newHighlighted
{
    highlighted = newHighlighted;
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx
{
    SCHReadingStoryInteractionButtonFillLayer *modelLayer = (SCHReadingStoryInteractionButtonFillLayer *)self.modelLayer;
    CGRect bounds = self.bounds;
    
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    CGContextTranslateCTM(ctx, 0, height);
    CGContextScaleCTM(ctx, 1, -1);
    
    CGRect rect = CGRectMake(self.fillInset.left , self.fillInset.bottom, width - self.fillInset.left - self.fillInset.right, ceilf((height - self.fillInset.top - self.fillInset.bottom)*self.fillLevel));

    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, rect);
    CGContextDrawImage(ctx, bounds, [modelLayer fillImage]);
    CGContextRestoreGState(ctx);
    
    if (self.highlighted) {
        CGContextClipToMask(ctx, bounds, [modelLayer fillImage]);
        CGContextSetBlendMode(ctx, kCGBlendModeDarken);
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.5);
        CGContextFillRect(ctx, bounds);
    }
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
    self.fillLayer.position = CGPointMake(fillImage.size.width/2, fillImage.size.height/2);
    
    BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    if (isYounger) {
        if (iPad) {
            self.fillLayer.fillInset = kSCHReadingStoryInteractionButtonFillInsetYounger;
        } else {
            self.fillLayer.fillInset = kSCHReadingStoryInteractionButtonFillInsetYounger_iPhone;
        }
    } else {
        if (iPad) {
            self.fillLayer.fillInset = kSCHReadingStoryInteractionButtonFillInsetOlder;
        } else {
            self.fillLayer.fillInset = kSCHReadingStoryInteractionButtonFillInsetOlder_iPhone;
        }
    }
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
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.fillLayer.fillLevel = fillLevel;
            [self.fillLayer removeAllAnimations];
            [CATransaction commit];
        }];
        [self.fillLayer addAnimation:animation forKey:@"fillAnimation"];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.fillLayer.fillLevel = level;
        [self.fillLayer setNeedsDisplay];
        [CATransaction commit];
    }
    fillLevel = level;
}

- (SCHReadingStoryInteractionButtonFillLayer *)fillLayer
{
    if (fillLayer == nil) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.fillLayer = [SCHReadingStoryInteractionButtonFillLayer layer];
        self.fillLayer.fillLevel = self.fillLevel;
        [self.imageView.layer addSublayer:self.fillLayer];
        [CATransaction commit];
    }
    return fillLayer;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.fillLayer setHighlighted:highlighted];
    [CATransaction commit];
}

@end
