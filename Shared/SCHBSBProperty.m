//
//  SCHBSBProperty.m
//  Scholastic
//
//  Created by Matt Farrugia on 30/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBProperty.h"

@implementation SCHBSBProperty

@synthesize name;
@synthesize value;

- (void)dealloc
{
    [name release], name = nil;
    [value release], value = nil;
    [super dealloc];
}

- (void)clear
{
    self.name = nil;
    self.value = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHBSBProperty: %p> { %@ : %@ }", self, self.name, self.value];
}

@end
