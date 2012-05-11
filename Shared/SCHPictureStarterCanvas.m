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

@interface SCHPictureStarterCanvas () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat deviceScale;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) CGPoint zoomOffset;
@property (nonatomic, retain) CALayer *backgroundLayer;
@property (nonatomic, retain) CALayer *paintedLayer;
@property (nonatomic, retain) CALayer *liveLayer;
@property (nonatomic, assign) CGContextRef paintContext;
@property (nonatomic, retain) id<SCHPictureStarterDrawingInstruction> currentInstruction;
@property (nonatomic, retain) SCHGestureSmoother *pinchSmoother;

- (void)cancelCurrentDrawingInstruction;
- (void)commitDrawingInstruction:(id<SCHPictureStarterDrawingInstruction>)instruction;
- (CGContextRef)newPaintContext;

@end;

@implementation SCHPictureStarterCanvas {
    CGPoint panStartPoint;
    CGPoint pinchStartCenter;
    CGPoint pinchStartOffset;
}

@synthesize delegate;
@synthesize deviceScale;
@synthesize zoomScale;
@synthesize zoomOffset;
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
        self.zoomOffset = CGPointZero;
        self.deviceScale = [[UIScreen mainScreen] scale];

        self.backgroundLayer = [CALayer layer];
        self.backgroundLayer.contentsGravity = kCAGravityResize;
        [self.layer addSublayer:self.backgroundLayer];
        
        self.paintedLayer = [CALayer layer];
        self.paintedLayer.contentsGravity = kCAGravityResize;
        [self.layer addSublayer:self.paintedLayer];
        
        self.liveLayer = [CALayer layer];
        self.liveLayer.contentsScale = self.deviceScale;
        self.liveLayer.contentsGravity = kCAGravityResize;
        [self.layer addSublayer:self.liveLayer];
        
        [self layoutSubviews];

        paintContext = [self newPaintContext];
        self.paintedLayer.contents = nil;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.backgroundLayer.bounds = self.bounds;
    self.backgroundLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.paintedLayer.bounds = self.backgroundLayer.bounds;
    self.paintedLayer.position = self.backgroundLayer.position;
    self.liveLayer.bounds = self.backgroundLayer.bounds;
    self.liveLayer.position = self.backgroundLayer.position;

    if (paintContext) {
        // grab the current image and redraw into the resized context
        CGImageRef currentContents = CGBitmapContextCreateImage(self.paintContext);
        paintContext = [self newPaintContext];
        CGContextDrawImage(paintContext, self.bounds, currentContents);
        CGImageRelease(currentContents);
    }
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
        case UIGestureRecognizerStateBegan: {
            [self cancelCurrentDrawingInstruction];
            CGPoint point = [pinch locationInView:self.superview];
            panStartPoint = point;
            pinchStartCenter = self.center;
            pinchStartOffset = CGPointMake(point.x-pinchStartCenter.x, point.y-pinchStartCenter.y);
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = [self adjustedCenterForPinch:pinch];
            [self setScale:self.zoomScale*pinch.scale animated:NO];
            [self setCenter:center clamped:NO animated:NO];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint center = [self adjustedCenterForPinch:pinch];
            self.zoomScale = MAX(1.0f, self.zoomScale*pinch.scale);
            [self setScale:self.zoomScale animated:YES];
            [self setCenter:center clamped:YES animated:YES];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self setScale:self.zoomScale animated:YES];
            [self setCenter:pinchStartCenter clamped:YES animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Zoom

- (CGPoint)adjustedCenterForPinch:(UIPinchGestureRecognizer *)pinch
{
    CGPoint point = [pinch locationInView:self.superview];
    CGFloat offsetX = pinchStartOffset.x*(pinch.scale-1.0f) + (panStartPoint.x-point.x);
    CGFloat offsetY = pinchStartOffset.y*(pinch.scale-1.0f) + (panStartPoint.y-point.y);
    CGPoint center = CGPointMake(pinchStartCenter.x-offsetX, pinchStartCenter.y-offsetY);
    return center;
}

- (void)setCenter:(CGPoint)center clamped:(BOOL)clamped animated:(BOOL)animated
{
    if (clamped) {
        CGFloat maxX = CGRectGetWidth(self.bounds)/2*self.zoomScale;
        CGFloat minX = CGRectGetMaxX(self.bounds)-maxX;
        CGFloat maxY = CGRectGetHeight(self.bounds)/2*self.zoomScale;
        CGFloat minY = CGRectGetMaxY(self.bounds)-maxY;
        center = CGPointMake(MAX(minX, MIN(maxX, center.x)),
                             MAX(minY, MIN(maxY, center.y)));
    }
    
    [UIView animateWithDuration:(animated ? 0.2f : 0.0f)
                     animations:^{
                         self.center = center;
                     }];
}

- (void)setScale:(CGFloat)scale animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? 0.2f : 0.0f)
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(scale, scale);
                     }];
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
