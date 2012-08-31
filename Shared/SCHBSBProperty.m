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
@synthesize node;

- (void)dealloc
{
    [name release], name = nil;
    [value release], value = nil;
    [node release], node = nil;
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHBSBProperty: %p> { %@ : %@ : %@ }", self, self.name, self.value, self.node];
}

@end
