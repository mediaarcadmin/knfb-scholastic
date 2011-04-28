//
//  SCHBookRange.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookRange.h"

@implementation SCHBookRange

@synthesize startPoint;
@synthesize endPoint;

- (void)dealloc
{
    [startPoint release], startPoint = nil;
    [endPoint release], endPoint = nil;
    [super dealloc];
}

@end
