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
    if ([self isImageNode] ||
        [self isVideoNode] || 
        [self isUIKitNode]) 
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

- (NSString *)inlineStyle
{
    if ([self isUIKitNode]) {
        return @"width: 300px; height: 60px;";
    }
    
    return [super inlineStyle];
}

@end
