//
//  SCHPictureStarterDrawingInstructions.m
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterDrawingInstruction.h"


@implementation SCHPictureStarterLineDrawingInstruction

@synthesize points;
@synthesize pointCount;
@synthesize pointCapacity;
@synthesize color;
@synthesize size;

- (void)dealloc
{
    [color release], color = nil;
    free(points), points = NULL;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.pointCapacity = 10;
        self.pointCount = 0;
        self.points = malloc(sizeof(CGPoint)*self.pointCapacity);
    }
    return self;
}

- (BOOL)shouldCommitInstantly
{
    return NO;
}

- (void)setScale:(CGFloat)scale
{
    self.size = MAX(self.size / scale, 0.1f);
}

- (void)updatePosition:(CGPoint)point
{
    if (self.pointCount == self.pointCapacity) {
        self.pointCapacity *= 2;
        self.points = realloc(self.points, sizeof(CGPoint)*self.pointCapacity);
    }
    self.points[self.pointCount++] = point;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if (layer) {
        CGContextTranslateCTM(context, 0, CGRectGetHeight(layer.bounds));
        CGContextScaleCTM(context, 1, -1);
    }
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetBlendMode(context, [self blendMode]);
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, size);
    if (self.pointCount > 0) {
        CGContextMoveToPoint(context, self.points[0].x, self.points[0].y);
    }
    for (NSInteger p = 1; p < self.pointCount; ++p) {
        CGContextAddLineToPoint(context, self.points[p].x, self.points[p].y);
    }
    CGContextDrawPath(context, kCGPathStroke);
}

- (CGBlendMode)blendMode
{
    return kCGBlendModeNormal;
}

@end

@implementation SCHPictureStarterEraseDrawingInstruction

- (BOOL)shouldCommitInstantly
{
    return YES;
}

- (CGBlendMode)blendMode
{
    return kCGBlendModeDestinationOut;
}

@end

@implementation SCHPictureStarterStickerDrawingInstruction

@synthesize sticker;
@synthesize point;
@synthesize scale;

- (void)dealloc
{
    [sticker release], sticker = nil;
    [super dealloc];
}

- (BOOL)shouldCommitInstantly
{
    return NO;
}

- (void)updatePosition:(CGPoint)newPoint
{
    self.point = newPoint;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if (layer) {
        CGContextTranslateCTM(context, 0, CGRectGetHeight(layer.bounds));
        CGContextScaleCTM(context, 1, -1);
    }
    
    CGSize size = CGSizeMake(self.sticker.size.width/self.scale, self.sticker.size.height/self.scale);
    CGRect rect = CGRectMake(self.point.x-size.width/2, self.point.y-size.height/2, size.width, size.height);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, [self.sticker CGImage]);
}

@end
