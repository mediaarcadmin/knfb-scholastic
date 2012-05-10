//
//  SCHBSBNode.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBNode.h"

@implementation SCHBSBNode

@synthesize nodeId;
@synthesize uri;

- (void)dealloc
{
    [nodeId release], nodeId = nil;
    [uri release], uri = nil;
    [super dealloc];
}

- (void)clearDecisions
{
    //noop
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHBSBNode: %p> { %@ : %@ }", self, self.nodeId, self.uri];
}

@end
