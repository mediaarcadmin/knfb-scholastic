//
//  SCHStoryInteractionProgressView.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionProgressView.h"

#define kImageWidth 21
#define kImageHeight 21
#define kImageGap 5

@interface SCHStoryInteractionProgressView ()

@property (nonatomic, retain) NSArray *indicators;

- (void)setupIndicators;

@end

@implementation SCHStoryInteractionProgressView

@synthesize numberOfSteps;
@synthesize currentStep;
@synthesize indicators;

- (void)dealloc
{
    [indicators release];
    [super dealloc];
}

- (void)setNumberOfSteps:(NSUInteger)aNumberOfSteps
{
    numberOfSteps = aNumberOfSteps;
    [self setupIndicators];
}

- (void)setCurrentStep:(NSUInteger)aCurrentStep
{
    currentStep = aCurrentStep;
    [self setupIndicators];
}

- (void)setupIndicators
{
    NSMutableArray *newIndicators = [NSMutableArray arrayWithCapacity:numberOfSteps];
    for (NSUInteger i = 0; i < numberOfSteps; ++i) {
        if (i == currentStep) {
            UIImage *image = [UIImage imageNamed:@"storyinteraction-progress-filled"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            imageView.backgroundColor = [UIColor clearColor];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
            label.text = [NSString stringWithFormat:@"%d", i+1];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.backgroundColor = [UIColor clearColor];
            label.textAlignment = UITextAlignmentCenter;
            UIView *container = [[UIView alloc] initWithFrame:CGRectZero];
            [container addSubview:imageView];
            [container addSubview:label];
            [container setBackgroundColor:[UIColor clearColor]];
            [newIndicators addObject:container];
            [container release];
            [imageView release];
            [label release];
        } else {
            UIImage *image = [UIImage imageNamed:@"storyinteraction-progress-unfilled"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            [newIndicators addObject:imageView];
            [imageView release];
        }
    }
    
    [self.indicators makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.indicators = [NSArray arrayWithArray:newIndicators];
    for (UIView *view in newIndicators) {
        [self addSubview:view];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat x = (width - numberOfSteps*kImageWidth - (numberOfSteps-1)*kImageGap) / 2;
    CGFloat y = (height - kImageHeight) / 2;
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(x, y, kImageWidth, kImageHeight);
        x += kImageWidth + kImageGap;
    }
}

@end
