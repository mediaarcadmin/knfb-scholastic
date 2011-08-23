//
//  SCHPictureStarterCanvas.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterCanvasDelegate.h"

@interface SCHPictureStarterCanvas ()

@property (nonatomic, assign) CGPoint pinchPoint;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) CGContextRef paintContext;

@end;

@implementation SCHPictureStarterCanvas

@synthesize delegate;
@synthesize backgroundImage;
@synthesize pinchPoint;
@synthesize zoomScale;
@synthesize paintContext;

- (void)dealloc
{
    [backgroundImage release], backgroundImage = nil;
    CGContextRelease(paintContext), paintContext = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinch];
        [pinch release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        [pan release];
        
        self.zoomScale = 1.0f;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        self.paintContext = CGBitmapContextCreate(NULL, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds),
                                                  8, 4*CGRectGetWidth(self.bounds), colorSpace, kCGImageAlphaPremultipliedLast);
        CGContextSetLineCap(self.paintContext, kCGLineCapRound);
        CGContextSaveGState(self.paintContext);
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, self.bounds, [self.backgroundImage CGImage]);
    
    CGImageRef paintImage = CGBitmapContextCreateImage(self.paintContext);
    CGContextDrawImage(context, self.bounds, paintImage);
    CGImageRelease(paintImage);
}

#pragma mark - Gesture recognition

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    [self.delegate canvas:self didReceiveTapAtPoint:[tap locationInView:self]];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if ([pan numberOfTouches] != 1) {
        return;
    }
    CGPoint point = [pan locationInView:self];
    switch ([pan state]) {
        case UIGestureRecognizerStateBegan:
            [self.delegate canvas:self didBeginDragAtPoint:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self.delegate canvas:self didMoveDragAtPoint:point];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self.delegate canvas:self didEndDragAtPoint:point];
            break;
        default:
            break;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    UIGestureRecognizerState state = [pinch state];
    if (state == UIGestureRecognizerStateBegan && self.zoomScale == 1.0f) {
        self.pinchPoint = [pinch locationInView:self];
        NSLog(@"start pinch at %@", NSStringFromCGPoint(self.pinchPoint));
    }
    CGFloat scale = self.zoomScale * [pinch scale];
    if (scale > 1.0f) {
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(-self.pinchPoint.x, -self.pinchPoint.y);
        CGAffineTransform t2 = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform t3 = CGAffineTransformMakeTranslation(self.pinchPoint.x, self.pinchPoint.y);
        self.transform = CGAffineTransformConcat(CGAffineTransformConcat(t1, t2), t3);
        NSLog(@"transform = %@", NSStringFromCGAffineTransform(self.transform));
    } else {
        self.transform = CGAffineTransformIdentity;
        scale = 1.0f;
    }
    
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        self.zoomScale = scale;
        CGContextRestoreGState(self.paintContext);
        CGContextSaveGState(self.paintContext);
        CGContextScaleCTM(self.paintContext, 1.0f/scale, 1.0f/scale);
    }
}

#pragma mark - Painting

- (CGRect)rectAtPoint:(CGPoint)center ofSize:(CGSize)size
{
    return CGRectMake(center.x-size.width/2, CGRectGetHeight(self.bounds)-center.y-size.height/2, size.width, size.height);
}

- (void)paintAtPoint:(CGPoint)point color:(UIColor *)color size:(NSInteger)size
{
    CGRect rect = [self rectAtPoint:point ofSize:CGSizeMake(size, size)];
    CGContextSetFillColorWithColor(self.paintContext, [color CGColor]);
    CGContextFillEllipseInRect(self.paintContext, rect);
    [self setNeedsDisplay];
}

- (void)paintLineFromPoint:(CGPoint)start toPoint:(CGPoint)end color:(UIColor *)color size:(NSInteger)size
{
    CGFloat height = CGRectGetHeight(self.bounds);
    CGContextSetStrokeColorWithColor(self.paintContext, [color CGColor]);
    CGContextSetLineWidth(self.paintContext, size);
    CGContextMoveToPoint(self.paintContext, start.x, height-start.y);
    CGContextAddLineToPoint(self.paintContext, end.x, height-end.y);
    CGContextDrawPath(self.paintContext, kCGPathStroke);
    [self setNeedsDisplay];
}

- (void)addSticker:(UIImage *)sticker atPoint:(CGPoint)point
{
    CGRect rect = [self rectAtPoint:point ofSize:sticker.size];
    CGContextDrawImage(self.paintContext, rect, [sticker CGImage]);
    [self setNeedsDisplay];
}

@end
