//
//  SCHPictureStarterSizeChooser.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterSizeChooser.h"

enum {
    kInset = 16,
    kGap = 16,
    kSelectionStrokeWidth = 4
};

@interface SCHPictureStarterSizeChooser ()
@property (nonatomic, retain) NSArray *sizes;
@property (nonatomic, retain) NSArray *sizeRects;
@property (nonatomic, assign) NSInteger selectedSizeIndex;
@end

@implementation SCHPictureStarterSizeChooser

@synthesize sizes;
@synthesize sizeRects;
@synthesize selectedSizeIndex;

- (void)dealloc
{
    [sizes release], sizes = nil;
    [sizeRects release], sizeRects = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sizes = [NSArray arrayWithObjects:
                      [NSNumber numberWithInteger:4],
                      [NSNumber numberWithInteger:8],
                      [NSNumber numberWithInteger:14],
                      [NSNumber numberWithInteger:20],
                      nil];
        self.selectedSizeIndex = NSNotFound;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

- (NSInteger)selectedSize
{
    if (self.selectedSizeIndex == NSNotFound ||
        self.selectedSizeIndex >= [self.sizes count]) {
        return NSNotFound;
    }
    return [[self.sizes objectAtIndex:self.selectedSizeIndex] integerValue];
}

- (void)clearSelection
{
    self.selectedSizeIndex = NSNotFound;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.4f, 0.4f, 0.4f, 1.0f);
    
    CGFloat width = 0;
    for (NSNumber *size in self.sizes) {
        width += kGap + [size integerValue]*2;
    }
    CGFloat x = kInset + (CGRectGetWidth(self.bounds)-kInset*2+kGap-width) / 2;
    CGFloat y = CGRectGetMidY(self.bounds);
    NSInteger index = 0;
    NSMutableArray *hitRects = [NSMutableArray arrayWithCapacity:[self.sizes count]];
    for (NSNumber *sizeObj in self.sizes) {
        NSInteger size = [sizeObj integerValue];
        CGRect rect = CGRectIntegral(CGRectMake(x, y-size, size*2, size*2));
        CGContextFillEllipseInRect(context, rect);
        if (index++ == self.selectedSizeIndex) {
            CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
            CGContextSetLineWidth(context, kSelectionStrokeWidth);
            CGContextStrokeEllipseInRect(context, CGRectInset(rect, kSelectionStrokeWidth/2.0f, kSelectionStrokeWidth/2.0f));
        }
        CGRect hitRect = CGRectMake(x-kGap/2, 0, size*2+kGap, CGRectGetHeight(self.bounds));
        [hitRects addObject:[NSValue valueWithCGRect:hitRect]];

        x = CGRectGetMaxX(rect) + kGap;
    }
    
    self.sizeRects = [NSArray arrayWithArray:hitRects];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    NSInteger index = 0;
    for (NSValue *rectObj in self.sizeRects) {
        if (CGRectContainsPoint([rectObj CGRectValue], point)) {
            self.selectedSizeIndex = index;
            break;
        }
        index++;
    }
}

- (void)setSelectedSizeIndex:(NSInteger)index
{
    if (index != self.selectedSizeIndex) {
        selectedSizeIndex = index;
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedSize:(NSInteger)newSize
{
    NSInteger index = 0;
    for (NSNumber *size in self.sizes) {
        if ([size integerValue] == newSize) {
            self.selectedSizeIndex = index;
            break;
        }
        index++;
    }
}

@end
