//
//  SCHPictureStarterCanvas.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterCanvasDelegate.h"
#import "SCHPictureStarterDrawingInstruction.h"
#import "SCHGeometry.h"
#import "SCHGestureSmoother.h"

#define kMinimumPinchOffset 20
#define kPinchInProgressMinimumZoom 1.0f
#define kEndOfPinchMinimumZoom 1.4f

@interface SCHPictureStarterCanvas ()

@property (nonatomic, assign) CGFloat deviceScale;
@property (nonatomic, assign) CGPoint pinchPoint;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, retain) CALayer *backgroundLayer;
@property (nonatomic, retain) CALayer *paintedLayer;
@property (nonatomic, retain) CALayer *liveLayer;
@property (nonatomic, assign) CGContextRef paintContext;
@property (nonatomic, retain) id<SCHPictureStarterDrawingInstruction> currentInstruction;
@property (nonatomic, retain) SCHGestureSmoother *pinchSmoother;

- (void)cancelCurrentDrawingInstruction;
- (void)commitDrawingInstruction:(id<SCHPictureStarterDrawingInstruction>)instruction;
- (CGContextRef)newPaintContext;
- (CGFloat)updateZoom:(CGFloat)scale point:(CGPoint)point minimumZoom:(CGFloat)minimumZoom animated:(BOOL)animated;

@end;

@implementation SCHPictureStarterCanvas

@synthesize delegate;
@synthesize deviceScale;
@synthesize pinchPoint;
@synthesize zoomScale;
@synthesize backgroundLayer;
@synthesize paintedLayer;
@synthesize liveLayer;
@synthesize paintContext;
@synthesize currentInstruction;
@synthesize pinchSmoother;

- (void)dealloc
{
    [backgroundLayer release], backgroundLayer = nil;
    [paintedLayer release], paintedLayer = nil;
    [liveLayer release], liveLayer = nil;
    [currentInstruction release], currentInstruction = nil;
    [pinchSmoother release], pinchSmoother = nil;
    
    if (paintContext) {
        CGContextRelease(paintContext), paintContext = NULL;
    }

    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinch];
        [pinch release];
        
        self.zoomScale = 1.0f;
        self.deviceScale = [[UIScreen mainScreen] scale];

        self.backgroundLayer = [CALayer layer];
        self.backgroundLayer.frame = self.bounds;
        self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self.layer addSublayer:self.backgroundLayer];
        
        self.paintedLayer = [CALayer layer];
        self.paintedLayer.frame = self.backgroundLayer.bounds;
        self.paintedLayer.position = self.backgroundLayer.position;
        [self.layer addSublayer:self.paintedLayer];
        
        self.liveLayer = [CALayer layer];
        self.liveLayer.frame = self.backgroundLayer.bounds;
        self.liveLayer.position = self.backgroundLayer.position;
        self.liveLayer.contentsScale = self.deviceScale;
        [self.layer addSublayer:self.liveLayer];

        paintContext = [self newPaintContext];
        
        self.paintedLayer.contents = nil;
    }
    return self;
}

- (CGContextRef)newPaintContext
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, CGRectGetWidth(self.bounds)*self.deviceScale, CGRectGetHeight(self.bounds)*self.deviceScale,
                                                 8, 4*CGRectGetWidth(self.bounds)*self.deviceScale, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextSetShouldAntialias(context, YES);
    CGContextConcatCTM(context, CGAffineTransformMakeScale(self.deviceScale, self.deviceScale));
    CGContextSaveGState(context);

    return context;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundLayer.contents = (id)[backgroundImage CGImage];
    [CATransaction commit];
}

#pragma mark - Gesture recognition

- (CGPoint)touchPoint:(NSSet *)touches
{
    UITouch *touch = [[touches objectEnumerator] nextObject];
    CGPoint p = [touch locationInView:self];
    return CGPointMake(p.x, CGRectGetHeight(self.bounds)-p.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // draw smaller on a smaller (i.e. iPhone) canvas
    const CGFloat sizeScale = (CGRectGetWidth(self.bounds) > 400) ? 1.0f : 2.0f;
    
    if ([touches count] == 1 && !self.currentInstruction) {
        // single touch = create new drawing instruction
        self.currentInstruction = [self.delegate drawingInstruction];
        [self.currentInstruction setScale:self.zoomScale*sizeScale];
        [self.currentInstruction updatePosition:[self touchPoint:touches]];
        self.liveLayer.delegate = self.currentInstruction;
        [self.liveLayer setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentInstruction) {
        [self.currentInstruction updatePosition:[self touchPoint:touches]];
        if ([self.currentInstruction shouldCommitInstantly]) {
            [self commitDrawingInstruction:self.currentInstruction];
        }
        [self.liveLayer setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.currentInstruction) {
        [self.currentInstruction updatePosition:[self touchPoint:touches]];
        [self commitDrawingInstruction:self.currentInstruction];
        [self cancelCurrentDrawingInstruction];
        [self.liveLayer setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancelCurrentDrawingInstruction];
}

- (void)cancelCurrentDrawingInstruction
{
    if (self.currentInstruction) {
        self.liveLayer.delegate = nil;
        self.currentInstruction = nil;
        [self.liveLayer setNeedsDisplay];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    switch ([pinch state]) {
        case UIGestureRecognizerStateBegan:
            [self cancelCurrentDrawingInstruction];
            self.pinchPoint = [pinch locationInView:self];
            self.pinchSmoother = [SCHGestureSmoother smoother];
            [self.pinchSmoother addPoint:[pinch locationInView:self]];
            break;
        case UIGestureRecognizerStateChanged:
            [self.pinchSmoother addPoint:[pinch locationInView:self]];
            [self updateZoom:pinch.scale point:[self.pinchSmoother smoothedPoint] minimumZoom:kPinchInProgressMinimumZoom animated:NO];
            break;
        case UIGestureRecognizerStateEnded:
            [self.pinchSmoother addPoint:[pinch locationInView:self]];
            self.zoomScale = [self updateZoom:pinch.scale point:[self.pinchSmoother smoothedPoint] minimumZoom:kPinchInProgressMinimumZoom animated:NO];
            self.pinchSmoother = nil;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self updateZoom:self.zoomScale point:self.pinchPoint minimumZoom:kEndOfPinchMinimumZoom animated:YES];
            self.pinchSmoother = nil;
            break;
        default:
            break;
    }
}

#pragma mark - Zoom

- (CGFloat)updateZoom:(CGFloat)scale point:(CGPoint)point minimumZoom:(CGFloat)minimumZoom animated:(BOOL)animated
{
    CGFloat absoluteScale = MIN(10.0f, self.zoomScale*scale);
    CGPoint translatePoint;
    if (absoluteScale < minimumZoom) {
        absoluteScale = 1.0f;
        translatePoint = self.pinchPoint;
    } else {
        translatePoint = CGPointMake(point.x*absoluteScale, point.y*absoluteScale);
    }
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(-self.pinchPoint.x, -self.pinchPoint.y);
    CGAffineTransform t2 = CGAffineTransformMakeScale(absoluteScale, absoluteScale);
    CGAffineTransform t3 = CGAffineTransformMakeTranslation(translatePoint.x, translatePoint.y);
    dispatch_block_t block = ^{
        self.transform = CGAffineTransformConcat(CGAffineTransformConcat(t1, t2), t3);
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:block];
    } else {
        block();
    }
    
    return absoluteScale;
}

#pragma mark - Painting

- (void)commitDrawingInstruction:(id<SCHPictureStarterDrawingInstruction>)instruction
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [instruction drawLayer:nil inContext:self.paintContext];

    CGImageRef image = CGBitmapContextCreateImage(self.paintContext);
    self.paintedLayer.contents = (id)image;
    CGImageRelease(image);
    
    [CATransaction commit];
    
    [self.delegate canvas:self didCommitDrawingInstruction:instruction];
}

- (void)clear
{    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.liveLayer.delegate = nil;
    self.currentInstruction = nil;
    
    if (paintContext) {
        CGContextRelease(paintContext), paintContext = NULL;
    }
    
    paintContext = [self newPaintContext];
    
    self.paintedLayer.contents = nil;
    [self.liveLayer setNeedsDisplay];
    
    [CATransaction commit];
}

- (CGImageRef)image
{
    CGContextRef context = [self newPaintContext];
    
    CGImageRef backgroundImage = (CGImageRef)self.backgroundLayer.contents;
    if (backgroundImage != NULL) {
        CGContextDrawImage(context, self.paintedLayer.bounds, backgroundImage);
    }
    
    CGImageRef paintedImage = (CGImageRef)self.paintedLayer.contents;
    CGContextDrawImage(context, self.paintedLayer.bounds, paintedImage);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    [(id)image autorelease];
    return image;
}

@end
