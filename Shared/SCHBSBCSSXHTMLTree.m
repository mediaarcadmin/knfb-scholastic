//
//  SCHBSBCSSXHTMLTree.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBCSSXHTMLTree.h"
#import "SCHBSBCSSXHTMLTreeNode.h"

@implementation SCHBSBCSSXHTMLTree

- (Class)xmlTreeNodeClass
{
    return [SCHBSBCSSXHTMLTreeNode class];
}

@end
