//
//  SCHPictureStarterDrawingList.m
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterDrawingList.h"

@protocol DrawingInstruction
- (void)drawInContext:(CGContextRef)context;
@end

@interface PointDrawingInstruction : NSObject <DrawingInstruction>
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) NSInteger size;
@end

@interface LineDrawingInstruction : NSObject <DrawingInstruction>
@property (nonatomic, assign) CGPoint start, end;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) NSInteger size;
@end

@interface StickerDrawingInstruction : NSObject <DrawingInstruction>
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, retain) UIImage *sticker;
@end

@interface SCHPictureStarterDrawingList ()
@property (nonatomic, retain) NSMutableArray *list;
@end

@implementation SCHPictureStarterDrawingList

@synthesize list;

- (void)dealloc
{
    [list release], list = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.list = [NSMutableArray array];
    }
    
    return self;
}

- (void)addPoint:(CGPoint)point color:(UIColor *)color size:(NSInteger)size
{
    PointDrawingInstruction *di = [[PointDrawingInstruction alloc] init];
    di.point = point;
    di.color = color;
    di.size = size;
    [self.list addObject:di];
    [di release];
}

- (void)addLineFrom:(CGPoint)start to:(CGPoint)end color:(UIColor *)color size:(NSInteger)size
{
    LineDrawingInstruction *di = [[LineDrawingInstruction alloc] init];
    di.start = start;
    di.end = end;
    di.color = color;
    di.size = size;
    [self.list addObject:di];
    [di release];
}

- (void)addSticker:(UIImage *)sticker atPoint:(CGPoint)point
{
    StickerDrawingInstruction *di = [[StickerDrawingInstruction alloc] init];
    di.point = point;
    di.sticker = sticker;
    [self.list addObject:di];
    [di release];
}

- (void)clear
{
    [self.list removeAllObjects];
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineCap(context, kCGLineCapRound);
    for (id<DrawingInstruction> di in self.list) {
        [di drawInContext:context];
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(layer.bounds));
    CGContextScaleCTM(ctx, 1, -1);
    [self drawInContext:ctx];
}

@end

@implementation PointDrawingInstruction

@synthesize point;
@synthesize color;
@synthesize size;

- (void)dealloc
{
    [color release], color = nil;
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = CGRectMake(self.point.x-self.size/2, self.point.y-self.size/2, self.size, self.size);
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    CGContextFillEllipseInRect(context, rect);
}

@end

@implementation LineDrawingInstruction

@synthesize start;
@synthesize end;
@synthesize color;
@synthesize size;

- (void)dealloc
{
    [color release], color = nil;
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, size);
    CGContextMoveToPoint(context, self.start.x, self.start.y);
    CGContextAddLineToPoint(context, self.end.x, self.end.y);
    CGContextDrawPath(context, kCGPathStroke);
}

@end

@implementation StickerDrawingInstruction

@synthesize sticker;
@synthesize point;

- (void)dealloc
{
    [sticker release], sticker = nil;
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)context
{
    CGSize size = self.sticker.size;
    CGRect rect = CGRectMake(self.point.x-size.width/2, self.point.y-size.height/2, size.width, size.height);
    CGContextDrawImage(context, rect, [self.sticker CGImage]);
}

@end

