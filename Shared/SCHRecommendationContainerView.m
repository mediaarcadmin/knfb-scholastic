//
//  SCHRecommendationContainerView.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationContainerView.h"

@implementation SCHRecommendationContainerView

@synthesize container;
@synthesize box;
@synthesize title;

- (void)awakeFromNib
{
    self.title.layer.cornerRadius = 10;
    self.title.layer.borderWidth = 1;
    self.title.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.box.layer.borderWidth = 1;
    self.box.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)dealloc
{
    [container release], container = nil;
    [box release], box = nil;
    [title release], title = nil;
    [super dealloc];
}

@end
