//
//  SCHStoryInteractionProgressView.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionProgressView.h"

#define kImageGap 5

@interface SCHStoryInteractionProgressView ()

@property (nonatomic, retain) NSArray *indicators;

- (void)setupIndicators;

@end

@implementation SCHStoryInteractionProgressView

@synthesize numberOfSteps;
@synthesize currentStep;
@synthesize indicators;
@synthesize youngerMode;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.youngerMode = NO;
    }
    
    return self;
}

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
    NSString *filledImageName = @"storyinteration-progress-filled";
    NSString *unfilledImageName = @"storyinteraction-progress-unfilled";
    
    if (self.youngerMode) {
        filledImageName = @"storyinteraction-younger-progress-filled";
        unfilledImageName = @"storyinteraction-younger-progress-unfilled";
    }

    
    NSMutableArray *newIndicators = [NSMutableArray arrayWithCapacity:numberOfSteps];
    for (NSUInteger i = 0; i < numberOfSteps; ++i) {
        if (i == currentStep) {
           
            
            UIImage *image = [UIImage imageNamed:filledImageName];
            
            
            
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
            UIImage *image = [UIImage imageNamed:unfilledImageName];
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

    NSString *filledImageName = @"storyinteration-progress-filled";
    
    if (self.youngerMode) {
        filledImageName = @"storyinteraction-younger-progress-filled";
    }
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    UIImage *image = [UIImage imageNamed:filledImageName];
    CGSize imageSize = image.size;
    
    CGFloat x = (width - numberOfSteps*imageSize.width - (numberOfSteps-1)*kImageGap) / 2;
    CGFloat y = (height - imageSize.height) / 2;
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(x, y, imageSize.width, imageSize.height);
        x += imageSize.width + kImageGap;
    }
}

@end
