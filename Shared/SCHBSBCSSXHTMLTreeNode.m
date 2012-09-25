//
//  SCHBSBCSSXHTMLTreeNode.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBCSSXHTMLTreeNode.h"

@implementation SCHBSBCSSXHTMLTreeNode


- (NSString *)namespace
{
    NSString *ret = [super namespace];
    
    if (!ret) {
        ret = @"http://www.w3.org/1999/xhtml";
    }
    
    return ret;
}

@end
