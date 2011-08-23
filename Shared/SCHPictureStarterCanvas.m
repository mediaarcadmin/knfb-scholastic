//
//  SCHPictureStarterCanvas.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterCanvas.h"
#import "SCHPictureStarterCanvasDelegate.h"
#import "SCHPictureStarterDrawingList.h"

@interface SCHPictureStarterCanvas ()

@property (nonatomic, assign) CGPoint pinchPoint;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, retain) CALayer *backgroundLayer;
@property (nonatomic, retain) CALayer *paintedLayer;
@property (nonatomic, retain) CALayer *liveLayer;
@property (nonatomic, assign) CGContextRef paintContext;
@property (nonatomic, retain) SCHPictureStarterDrawingList *drawingList;

@end;

@implementation SCHPictureStarterCanvas

@synthesize delegate;
@synthesize pinchPoint;
@synthesize zoomScale;
@synthesize backgroundLayer;
@synthesize paintedLayer;
@synthesize liveLayer;
@synthesize paintContext;
@synthesize drawingList;

- (void)dealloc
{
    [backgroundLayer release], backgroundLayer = nil;
    [paintedLayer release], paintedLayer = nil;
    [liveLayer release], liveLayer = nil;
    [drawingList release], drawingList = nil;
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
        self.drawingList = [[[SCHPictureStarterDrawingList alloc] init] autorelease];
        
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
        self.liveLayer.delegate = self.drawingList;
        [self.layer addSublayer:self.liveLayer];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        self.paintContext = CGBitmapContextCreate(NULL, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds),
                                                  8, 4*CGRectGetWidth(self.bounds), colorSpace, kCGImageAlphaPremultipliedLast);
        CGContextSaveGState(self.paintContext);
    }
    return self;
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

- (void)setNeedsCommit
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commit) object:nil];
    [self performSelector:@selector(commit) withObject:nil afterDelay:1.0];
    [self.liveLayer setNeedsDisplay];
}

- (void)paintAtPoint:(CGPoint)point color:(UIColor *)color size:(NSInteger)size
{
    point.y = CGRectGetHeight(self.bounds)-point.y;
    [self.drawingList addPoint:point color:color size:size];
    [self setNeedsCommit];
}

- (void)paintLineFromPoint:(CGPoint)start toPoint:(CGPoint)end color:(UIColor *)color size:(NSInteger)size
{
    CGFloat height = CGRectGetHeight(self.bounds);
    start.y = height-start.y;
    end.y = height-end.y;
    
    [self.drawingList addLineFrom:start to:end color:color size:size];
    [self setNeedsCommit];
}

- (void)addSticker:(UIImage *)sticker atPoint:(CGPoint)point
{
    point.y = CGRectGetHeight(self.bounds)-point.y;
    [self.drawingList addSticker:sticker atPoint:point];
    [self setNeedsCommit];
}

- (void)commit
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.drawingList drawInContext:self.paintContext];
    CGImageRef image = CGBitmapContextCreateImage(self.paintContext);
    self.paintedLayer.contents = (id)image;
    CGImageRelease(image);
    [self.drawingList clear];
    [self.liveLayer setNeedsDisplay];
    
    [CATransaction commit];
}

@end
