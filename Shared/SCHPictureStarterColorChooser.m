//
//  SCHPictureStarterColorChooser.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterColorChooser.h"
#import "UIColor+Scholastic.h"

enum {
    kGap = 3,
    kInsetX = 8,
    kInsetY = 8,
    kNumberOfColumns = 4,
    kSelectionStrokeWidth = 4
};

@interface SCHPictureStarterColorChooser ()
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, assign) NSInteger selectedColorIndex;
@property (nonatomic, assign) CGSize paintSize;
@end

@implementation SCHPictureStarterColorChooser

@synthesize colors;
@synthesize selectedColorIndex;
@synthesize paintSize;

- (void)dealloc
{
    [colors release], colors = nil;
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.colors = [NSArray arrayWithObjects:
                       [UIColor clearColor],
                       [UIColor SCHBlackColor],
                       [UIColor SCHGrayColor],
                       [UIColor SCHGray2Color],
                       [UIColor SCHRed4Color],
                       [UIColor SCHRed2Color],
                       [UIColor SCHPurple1Color], // pale pink
                       [UIColor SCHPurple2Color], // deep pink
                       [UIColor SCHGreen1Color],
                       [UIColor SCHGreen2Color],
                       [UIColor SCHLightBlue1Color],
                       [UIColor SCHBlue1Color],
                       [UIColor SCHOrange1Color],
                       [UIColor SCHOrange2Color],
                       [UIColor SCHPurple2Color],
                       [UIColor SCHYellowColor],
                       nil];
        self.selectedColorIndex = NSNotFound;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

- (UIColor *)selectedColor
{
    if (self.selectedColorIndex == NSNotFound) {
        return nil;
    }
    return [self.colors objectAtIndex:self.selectedColorIndex];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSInteger cols = kNumberOfColumns;
    NSInteger rows = [self.colors count] / cols;
    NSInteger index = 0;
    self.paintSize = CGSizeMake(floorf((CGRectGetWidth(self.bounds)-kInsetX*2+kGap)/cols-kGap),
                                floorf((CGRectGetHeight(self.bounds)-kInsetY*2+kGap)/rows-kGap));
    for (UIColor *color in self.colors) {
        CGRect rect = CGRectMake(kInsetX+(index%cols)*(self.paintSize.width+kGap),
                                 kInsetY+(index/cols)*(self.paintSize.height+kGap),
                                 self.paintSize.width, self.paintSize.height);
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, rect);
        
        if (index == 0) {
            CGContextSaveGState(context);
            CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
            CGContextSetLineWidth(context, 6);
            CGContextSetLineCap(context, kCGLineCapSquare);
            CGContextClipToRect(context, rect);
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
        
        if (index == self.selectedColorIndex) {
            CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
            CGContextSetLineWidth(context, kSelectionStrokeWidth);
            CGContextStrokeRect(context, CGRectInset(rect, kSelectionStrokeWidth/2.0f, kSelectionStrokeWidth/2.0f));
        }
        
        index++;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    CGPoint p = [tap locationInView:self];
    NSInteger col = (p.x-kInsetX) / (self.paintSize.width+kGap);
    NSInteger row = (p.y-kInsetY) / (self.paintSize.height+kGap);
    if (0 <= col && col < kNumberOfColumns && 0 <= row && row < ([self.colors count]/kNumberOfColumns)) {
        self.selectedColorIndex = row*kNumberOfColumns+col;
    }
}

- (void)setSelectedColorIndex:(NSInteger)index
{
    if (index != self.selectedColorIndex) {
        selectedColorIndex = index;
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
