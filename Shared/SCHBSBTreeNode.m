//
//  SCHBSBTreeNode.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBTreeNode.h"

@implementation SCHBSBTreeNode

- (BOOL)isReplacedNode
{
    if ([self isUIKitNode]) 
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isUIKitNode
{
    if ([[self attributeWithName:@"data-type"] length]) {
        return YES;
    }
    
    return NO;
}

@end