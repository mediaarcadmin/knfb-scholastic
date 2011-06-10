//
//  SCHStoryInteractionScratchView.m
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionScratchView.h"

static const float kSCHScratchEraseSize = 24.0f;

@interface SCHStoryInteractionScratchView ()

@property (nonatomic, retain) NSMutableArray *pointsArray;
@property (nonatomic, assign) BOOL firstDraw;

- (void)clipImage: (CGRect)rect;
- (void)updateDelegate;

@end

@implementation SCHStoryInteractionScratchView

@synthesize delegate;
@synthesize answerImage;
@synthesize pointsArray;
@synthesize firstDraw;
@synthesize interactionEnabled;
@synthesize showFullImage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.firstDraw = YES;
        self.pointsArray = [[NSMutableArray alloc] init];
        self.interactionEnabled = YES;
        self.showFullImage = NO;

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.pointsArray || [self.pointsArray count] < 2) {
        return;
    }
    
    [self clipImage:rect];
}

- (void)setAnswerImage:(UIImage *)newAnswerImage
{
    UIImage *oldImage = answerImage;
    answerImage = [newAnswerImage retain];
    [oldImage release];
    
    [self.pointsArray removeAllObjects];
    self.interactionEnabled = YES;
    self.showFullImage = NO;
    
    [self setNeedsDisplay];

}

- (void)setShowFullImage:(BOOL)aShowFullImage
{
    showFullImage = aShowFullImage;
    [self setNeedsDisplay];
}

- (void)clipImage: (CGRect)rect
{
    UIImage *img = self.answerImage;

    CGRect bounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
    if (!showFullImage) {    
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGMutablePathRef path = CGPathCreateMutable();
        
        for (int i = 0; i < [self.pointsArray count] - 1; i++) {
            CGPoint pt = [(NSValue *) [self.pointsArray objectAtIndex:i] CGPointValue];
            CGPathAddEllipseInRect(path, NULL, CGRectMake(pt.x - (kSCHScratchEraseSize/2), pt.y - (kSCHScratchEraseSize/2), kSCHScratchEraseSize, kSCHScratchEraseSize));
        }
        
        CGContextAddPath(context, path);
        CGContextClip(context);
    }
    [img drawInRect:bounds];
}

- (void)dealloc
{
    delegate = nil;
    [answerImage release], answerImage = nil;
    [pointsArray release], pointsArray = nil;
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.interactionEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        [self.pointsArray addObject:[NSValue valueWithCGPoint:touchLocation]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.interactionEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        if (touchLocation.x >= 0 && touchLocation.x <= self.frame.size.width
            && touchLocation.y >= 0 && touchLocation.y <= self.frame.size.height) {
            [self.pointsArray addObject:[NSValue valueWithCGPoint:touchLocation]];
            [self setNeedsDisplay];
            [self updateDelegate];
        }
    }
}

- (void)updateDelegate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scratchView:uncoveredPoints:)]) {
        [self.delegate scratchView:self uncoveredPoints:[self.pointsArray count]];
    }
}


@end
