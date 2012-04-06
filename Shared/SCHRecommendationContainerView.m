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

- (void)dealloc
{
    [container release], container = nil;
    [box release], box = nil;
    [super dealloc];
}

@end
