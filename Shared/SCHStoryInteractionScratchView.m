//
//  SCHStoryInteractionScratchView.m
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionScratchView.h"
#import <QuartzCore/QuartzCore.h>

static const float kSCHScratchEraseSize = 24.0f;

@interface SCHStoryInteractionScratchView ()

@property (nonatomic, retain) NSMutableArray *pointsArray;
@property (nonatomic, retain) CAShapeLayer *mask;
@property (nonatomic, retain) CALayer *maskImageLayer;
@property (nonatomic, retain) CALayer *answerImageLayer;

- (void)updateDelegate;

@end

@implementation SCHStoryInteractionScratchView

@synthesize delegate;
@synthesize answerImage;
@synthesize pointsArray;
@synthesize interactionEnabled;
@synthesize mask;
@synthesize maskImageLayer;
@synthesize answerImageLayer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.pointsArray = [NSMutableArray array];
        self.interactionEnabled = YES;
        
        maskImageLayer = [[CALayer layer] retain];
        maskImageLayer.frame = self.layer.bounds;
        maskImageLayer.contents = (id)[UIImage imageNamed:@"storyinteraction-initialScratch"].CGImage;
        [self.layer addSublayer:maskImageLayer];
        
        answerImageLayer = [[CALayer layer] retain];
        answerImageLayer.frame = self.layer.bounds;
        [self.layer addSublayer:answerImageLayer];
                
        mask = [[CAShapeLayer layer] retain];
        mask.backgroundColor = [UIColor clearColor].CGColor;
        mask.frame = self.layer.bounds;
        answerImageLayer.mask = mask;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.answerImageLayer.bounds = self.layer.bounds;
    self.maskImageLayer.bounds = self.layer.bounds;
    self.mask.bounds = self.layer.bounds;

}

- (void)setAnswerImage:(UIImage *)newAnswerImage
{
    UIImage *oldImage = answerImage;
    answerImage = [newAnswerImage retain];
    [oldImage release];
    
    [self.pointsArray removeAllObjects];
    self.interactionEnabled = YES;
    [self setShowFullImage:NO];
    
    self.answerImageLayer.contents = (id)answerImage.CGImage;
}

- (void)setShowFullImage:(BOOL)showFullImage
{    
    if (showFullImage) {
        answerImageLayer.mask = nil;
    } else {
        answerImageLayer.mask = mask;
    }
}

- (void)dealloc
{
    delegate = nil;
    [answerImage release], answerImage = nil;
    [pointsArray release], pointsArray = nil;
    [mask release], mask = nil;
    [maskImageLayer release], maskImageLayer = nil;
    [answerImageLayer release], answerImageLayer = nil;
    
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.interactionEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        [self.pointsArray addObject:[NSValue valueWithCGPoint:touchLocation]];
    }
}

static CGFloat distanceBetweenPoints(CGPoint pt1, CGPoint pt2)
{
    CGFloat dx = pt1.x - pt2.x;
    CGFloat dy = pt1.y - pt2.y;
    return dx*dx+dy*dy;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {    
    if (self.interactionEnabled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];

        if (touchLocation.x >= 0 && touchLocation.x <= self.frame.size.width
            && touchLocation.y >= 0 && touchLocation.y <= self.frame.size.height) {
            
            __block BOOL tooClose = NO;
            
            [self.pointsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (distanceBetweenPoints(touchLocation, [obj CGPointValue]) < kSCHScratchEraseSize) {
                    *stop = YES;
                    tooClose = YES;
                }
            }];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(scratchViewWasScratched:)]) {
                [self.delegate scratchViewWasScratched:self];
            }
             
            if (tooClose) {
                return;
            }
                    
            [self.pointsArray addObject:[NSValue valueWithCGPoint:touchLocation]];
            
            CGMutablePathRef updatedPath;
            
            if (self.mask.path) {
                updatedPath = CGPathCreateMutableCopy(self.mask.path);
            } else {
                updatedPath = CGPathCreateMutable();
            }
                
            CGPathAddEllipseInRect(updatedPath, NULL, CGRectMake(touchLocation.x - (kSCHScratchEraseSize/2), touchLocation.y - (kSCHScratchEraseSize/2), kSCHScratchEraseSize, kSCHScratchEraseSize));
            self.mask.path = updatedPath;
            CGPathRelease(updatedPath);
            
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
