//
//  SCHStoryInteractionWordSearchContainerView.m
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionWordSearchContainerView.h"
#import "SCHStoryInteractionWordSearch.h"

@interface SelectionLayer : CALayer {}
@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGSize letterSize;
@property (nonatomic, assign) NSInteger letterGap;
@property (nonatomic, assign) NSInteger startRow;
@property (nonatomic, assign) NSInteger startColumn;
@property (nonatomic, assign) NSInteger extent;
@property (nonatomic, assign) BOOL isVertical;
@end

@interface SCHStoryInteractionWordSearchContainerView ()

@property (nonatomic, assign) CGRect letterArea;
@property (nonatomic, assign) CGSize letterSize;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property (nonatomic, assign) CGPoint selectionStartPoint;
@property (nonatomic, retain) SelectionLayer *selectionLayer;

@end

@implementation SCHStoryInteractionWordSearchContainerView

@synthesize delegate;
@synthesize letterGap;
@synthesize letterArea;
@synthesize letterSize;
@synthesize numberOfRows;
@synthesize numberOfColumns;
@synthesize selectionStartPoint;
@synthesize selectionLayer;

- (void)dealloc
{
    [selectionLayer release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:pan];
        [pan release];
        self.userInteractionEnabled = YES;

        self.selectionLayer = [SelectionLayer layer];
        self.selectionLayer.color = [UIColor yellowColor];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"phase"];
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        animation.toValue = [NSNumber numberWithFloat:10.0];
        animation.duration = 1.0;
        animation.repeatCount = CGFLOAT_MAX;
        [self.selectionLayer addAnimation:animation forKey:@"marching-ants"];
    }
    return self;
}

- (void)populateFromWordSearchModel:(SCHStoryInteractionWordSearch *)wordSearch
                withLetterTileImage:(UIImage *)letterBackground
{
    self.numberOfRows = [wordSearch matrixRows];
    self.numberOfColumns = [wordSearch matrixColumns];
    const CGFloat scale = [[UIScreen mainScreen] scale];
    self.letterSize = CGSizeMake(letterBackground.size.width / scale, letterBackground.size.height / scale);
    CGSize letterAreaSize = CGSizeMake(self.numberOfColumns * self.letterSize.width + (self.numberOfColumns-1) * self.letterGap,
                                       self.numberOfRows * self.letterSize.height + (self.numberOfRows-1) * self.letterGap);
    self.letterArea = CGRectMake((self.bounds.size.width - letterAreaSize.width) / 2,
                                 (self.bounds.size.height - letterAreaSize.height) / 2,
                                 letterAreaSize.width, letterAreaSize.height);
    CGFloat y = self.letterArea.origin.y;
    for (int row = 0; row < self.numberOfRows; ++row) {
        CGFloat x = self.letterArea.origin.x;
        for (int col = 0; col < self.numberOfColumns; ++col) {
            UIImageView *bg = [[UIImageView alloc] initWithImage:letterBackground];
            bg.frame = CGRectMake(x, y, self.letterSize.width, self.letterSize.height);
            UILabel *label = [[UILabel alloc] initWithFrame:bg.bounds];
            unichar letter = [wordSearch matrixLetterAtRow:row column:col];
            label.text = [NSString stringWithCharacters:&letter length:1];
            label.font = [UIFont boldSystemFontOfSize:20];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            [bg addSubview:label];
            [label release];
            [self addSubview:bg];
            [bg release];
            x += self.letterSize.width + self.letterGap;
        }
        y += self.letterSize.height + self.letterGap;
    }
    
    [self clearSelection];
    
    [self.selectionLayer removeFromSuperlayer];
    self.selectionLayer.bounds = CGRectMake(0, 0, self.letterArea.size.width, self.letterArea.size.height);
    self.selectionLayer.position = CGPointMake(CGRectGetMidX(self.letterArea), CGRectGetMidY(self.letterArea));
    self.selectionLayer.letterSize = self.letterSize;
    self.selectionLayer.letterGap = self.letterGap;
    [self.layer addSublayer:self.selectionLayer];
}

- (void)clearSelection
{
    self.selectionLayer.extent = 0;
}

- (void)addPermanentHighlightFromCurrentSelectionWithColor:(UIColor *)color
{
    SelectionLayer *highlight = [SelectionLayer layer];
    highlight.bounds = self.selectionLayer.bounds;
    highlight.position = self.selectionLayer.position;
    highlight.letterSize = self.letterSize;
    highlight.letterGap = self.letterGap;
    highlight.color = color;
    highlight.startColumn = self.selectionLayer.startColumn;
    highlight.startRow = self.selectionLayer.startRow;
    highlight.extent = self.selectionLayer.extent;
    highlight.isVertical = self.selectionLayer.isVertical;
    highlight.phase = -1;
    [self.layer addSublayer:highlight];
    [highlight setNeedsDisplay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    if ([pan state] == UIGestureRecognizerStateBegan) {
        self.selectionStartPoint = [pan locationInView:self];
        NSLog(@"selectionStartPoint=%@", NSStringFromCGPoint(self.selectionStartPoint));
    }
    CGPoint translation = [pan translationInView:self];
    CGPoint endPoint = CGPointMake(self.selectionStartPoint.x + translation.x,
                                   self.selectionStartPoint.y + translation.y);
    CGFloat stepWidth = self.letterSize.width + self.letterGap;
    CGFloat stepHeight = self.letterSize.height + self.letterGap;

    NSInteger startCol = (NSInteger)((self.selectionStartPoint.x - self.letterArea.origin.x) / stepWidth);
    NSInteger startRow = (NSInteger)((self.selectionStartPoint.y - self.letterArea.origin.y) / stepHeight);
    NSInteger endCol = (NSInteger)((endPoint.x - self.letterArea.origin.x) / stepWidth);
    NSInteger endRow = (NSInteger)((endPoint.y - self.letterArea.origin.y) / stepHeight);
    NSInteger extentCols = endCol - startCol;
    NSInteger extentRows = endRow - startRow;
    
    [self clearSelection];
    
    if ((extentCols == 0 && extentRows == 0) || (extentCols > 0 && extentRows > 0)) {
        return;
    }
    if (startCol < 0 || self.numberOfColumns <= startCol || startRow < 0 || self.numberOfRows <= startRow) {
        return;
    }
    
    if (extentCols > 0) {
        self.selectionLayer.startColumn = startCol;
        self.selectionLayer.startRow = startRow;
        self.selectionLayer.extent = MIN(extentCols + 1, self.numberOfColumns-startCol);
        self.selectionLayer.isVertical = NO;
    } else if (extentCols < 0) {
        self.selectionLayer.startColumn = MAX(0, startCol + extentCols);
        self.selectionLayer.startRow = startRow;
        self.selectionLayer.extent = MIN(-extentCols + 1, self.numberOfColumns-startCol);
        self.selectionLayer.isVertical = NO;
    } else if (extentRows > 0) {
        self.selectionLayer.startColumn = startCol;
        self.selectionLayer.startRow = startRow;
        self.selectionLayer.extent = MIN(extentRows + 1, self.numberOfRows-startRow);
        self.selectionLayer.isVertical = YES;
    } else if (extentRows < 0) {
        self.selectionLayer.startColumn = startCol;
        self.selectionLayer.startRow = MAX(0, startRow + extentRows);
        self.selectionLayer.extent = MIN(-extentRows + 1, self.numberOfRows-startRow);
        self.selectionLayer.isVertical = YES;
    }
    
    if ([pan state] == UIGestureRecognizerStateEnded) {
        [self.delegate letterContainer:self
                 didSelectFromStartRow:self.selectionLayer.startRow
                           startColumn:self.selectionLayer.startColumn
                                extent:self.selectionLayer.extent
                            vertically:self.selectionLayer.isVertical];
    }
}

@end

@implementation SelectionLayer

#define kInset 4

@synthesize phase;
@synthesize color;
@synthesize letterSize;
@synthesize letterGap;
@synthesize startRow;
@synthesize startColumn;
@synthesize extent;
@synthesize isVertical;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"phase"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)dealloc
{
    [color release];
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)context
{
    SelectionLayer *model = (SelectionLayer *)[self modelLayer];
    if (model.extent == 0) {
        return;
    }

    CGContextSetStrokeColorWithColor(context, [model.color CGColor]);
    CGContextSetLineWidth(context, 3);
    
    if (self.phase >= 0) {
        static const CGFloat kDashLengths[2] = { 5.0, 5.0 };
        CGContextSetLineDash(context, self.phase, kDashLengths, sizeof(kDashLengths)/sizeof(kDashLengths[0]));
    }
    
    CGFloat x1 = (model.letterSize.width + model.letterGap) * model.startColumn + kInset;
    CGFloat y1 = (model.letterSize.height + model.letterGap) * model.startRow + kInset;
    if (model.isVertical) {
        CGFloat x2 = x1 + model.letterSize.width - kInset*2;
        CGFloat y2 = y1 + (model.letterSize.height * model.extent) + model.letterGap * (model.extent-1) - kInset*2;
        CGFloat radius = (x2-x1)/2;
        CGContextMoveToPoint(context, x1, y2-radius);
        CGContextAddArc(context, (x1+x2)/2, y2-radius, radius, M_PI, 0, YES);
        CGContextAddLineToPoint(context, x2, y1+radius);
        CGContextAddArc(context, (x1+x2)/2, y1+radius, radius, 0, M_PI, YES);
        CGContextClosePath(context);
    } else {
        CGFloat x2 = x1 + (model.letterSize.width * model.extent) + model.letterGap * (model.extent-1) - kInset*2;
        CGFloat y2 = y1 + model.letterSize.height - kInset*2;
        CGFloat radius = (y2-y1)/2;
        CGContextMoveToPoint(context, x2-radius, y1);
        CGContextAddArc(context, x2-radius, (y1+y2)/2, radius, -M_PI/2, M_PI/2, NO);
        CGContextAddLineToPoint(context, x1+radius, y2);
        CGContextAddArc(context, x1+radius, (y1+y2)/2, radius, M_PI/2, -M_PI/2, NO);
        CGContextClosePath(context);
    }
    
    CGContextStrokePath(context);
}

@end
