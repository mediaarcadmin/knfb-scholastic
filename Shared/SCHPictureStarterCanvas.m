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

@interface SCHPictureStarterCanvas ()

@property (nonatomic, assign) CGPoint pinchPoint;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, retain) CALayer *backgroundLayer;
@property (nonatomic, retain) CALayer *paintedLayer;
@property (nonatomic, retain) CALayer *liveLayer;
@property (nonatomic, assign) CGContextRef paintContext;
@property (nonatomic, retain) id<SCHPictureStarterDrawingInstruction> currentInstruction;

- (void)commitDrawingInstruction:(id<SCHPictureStarterDrawingInstruction>)instruction;
- (void)createPaintContext;

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

- (void)dealloc
{
    [backgroundLayer release], backgroundLayer = nil;
    [paintedLayer release], paintedLayer = nil;
    [liveLayer release], liveLayer = nil;
    [currentInstruction release], currentInstruction = nil;
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        [pan release];

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

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    point.y = CGRectGetHeight(self.bounds) - point.y;
    
    id<SCHPictureStarterDrawingInstruction> di = [self.delegate drawingInstruction];
    [di updatePosition:point];
    [self commitDrawingInstruction:di];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if ([pan numberOfTouches] != 1) {
        return;
    }
    
    CGPoint point = [pan locationInView:self];
    point.y = CGRectGetHeight(self.bounds) - point.y;
   
    switch ([pan state]) {
        case UIGestureRecognizerStateBegan: {
            if (self.currentInstruction != nil) {
                [self commitDrawingInstruction:self.currentInstruction];
            }
            self.currentInstruction = [self.delegate drawingInstruction];
            [self.currentInstruction updatePosition:point];
            self.liveLayer.delegate = self.currentInstruction;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.currentInstruction updatePosition:point];
            if ([self.currentInstruction shouldCommitInstantly]) {
                [self commitDrawingInstruction:self.currentInstruction];
            }
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            self.liveLayer.delegate = nil;
            self.currentInstruction = nil;
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.currentInstruction updatePosition:point];
            [self commitDrawingInstruction:self.currentInstruction];
            self.liveLayer.delegate = nil;
            self.currentInstruction = nil;
            break;
        }
        default:
            break;
    }

    [self.liveLayer setNeedsDisplay];
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
