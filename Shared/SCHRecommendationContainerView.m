//
//  SCHRecommendationContainerView.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationContainerView.h"
#import "UILabel+ScholasticAdditions.h"

@implementation SCHRecommendationContainerView

@synthesize container;
@synthesize box;
@synthesize heading;

- (void)awakeFromNib
{
    self.heading.layer.cornerRadius = 10;
    self.heading.layer.borderWidth = 1;
    self.heading.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.box.layer.borderWidth = 1;
    self.box.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.heading adjustPointSizeToFitWidthWithPadding:2.0f];
}

- (void)dealloc
{
    [container release], container = nil;
    [box release], box = nil;
    [heading release], heading = nil;
    [super dealloc];
}

@end
