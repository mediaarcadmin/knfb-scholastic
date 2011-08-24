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

@interface SCHPictureStarterCanvas ()

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
- (void)createPaintContext;
- (CGFloat)updateZoom:(CGFloat)scale point:(CGPoint)point;

@end;

@implementation SCHPictureStarterCanvas

@synthesize delegate;
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
    CGContextRelease(paintContext), paintContext = NULL;
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
        
        self.backgroundLayer = [CALayer layer];
        self.backgroundLayer.frame = self.bounds;
        self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self.layer addSublayer:self.backgroundLayer];
        
        self.paintedLayer = [CALayer layer];
        self.paintedLayer.frame = self.bounds;
        self.paintedLayer.position = self.backgroundLayer.position;
        [self.layer addSublayer:self.paintedLayer];
        
        self.liveLayer = [CALayer layer];
        self.liveLayer.frame = self.bounds;
        self.liveLayer.position = self.backgroundLayer.position;
        [self.layer addSublayer:self.liveLayer];

        [self createPaintContext];
    }
    return self;
}

- (void)createPaintContext
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    self.paintContext = CGBitmapContextCreate(NULL, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds),
                                              8, 4*CGRectGetWidth(self.bounds), colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextSaveGState(self.paintContext);
    
    self.paintedLayer.contents = nil;
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
    CGPoint p = [[touches anyObject] locationInView:self];
    return CGPointMake(p.x, CGRectGetHeight(self.bounds)-p.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1) {
        // single touch = create new drawing instruction
        self.currentInstruction = [self.delegate drawingInstruction];
        [self.currentInstruction setScale:self.zoomScale];
        [self.currentInstruction updatePosition:[self touchPoint:touches]];
        self.liveLayer.delegate = self.currentInstruction;
        [self.liveLayer setNeedsDisplay];
    } else {
        [self cancelCurrentDrawingInstruction];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1 && self.currentInstruction) {
        [self.currentInstruction updatePosition:[self touchPoint:touches]];
        if ([self.currentInstruction shouldCommitInstantly]) {
            [self commitDrawingInstruction:self.currentInstruction];
        }
        [self.liveLayer setNeedsDisplay];
    } else {
        [self cancelCurrentDrawingInstruction];
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
            self.pinchPoint = [pinch locationInView:self];
            self.pinchSmoother = [SCHGestureSmoother smoother];
            break;
        case UIGestureRecognizerStateChanged:
            [self.pinchSmoother addPoint:[pinch locationInView:self]];
            [self updateZoom:pinch.scale point:[self.pinchSmoother smoothedPoint]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.pinchSmoother addPoint:[pinch locationInView:self]];
            self.zoomScale = [self updateZoom:pinch.scale point:[self.pinchSmoother smoothedPoint]];
            self.pinchSmoother = nil;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self updateZoom:self.zoomScale point:self.pinchPoint];
            self.pinchSmoother = nil;
            break;
        default:
            break;
    }
}

#pragma mark - Zoom

- (CGFloat)updateZoom:(CGFloat)scale point:(CGPoint)point
{
    scale = MIN(10.0f, self.zoomScale*scale);
    if (scale < 1.0f) {
        scale = 1.0f;
        point = self.pinchPoint;
    }
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(-self.pinchPoint.x, -self.pinchPoint.y);
    CGAffineTransform t2 = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform t3 = CGAffineTransformMakeTranslation(point.x*scale, point.y*scale);
    self.transform = CGAffineTransformConcat(CGAffineTransformConcat(t1, t2), t3);
    
    return scale;
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
}

- (void)clear
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.liveLayer.delegate = nil;
    self.currentInstruction = nil;
    [self createPaintContext];
    [self.liveLayer setNeedsDisplay];
    
    [CATransaction commit];
}

@end
