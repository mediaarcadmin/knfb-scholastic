// 
//  SCHLocationText.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHLocationText.h"

#import "SCHHighlight.h"
#import "SCHWordIndex.h"

// Constants
NSString * const kSCHLocationText = @"SCHLocationText";

@implementation SCHLocationText 

@dynamic Page;
@dynamic WordIndex;
@dynamic Highlight;

- (void)setInitialValues
{
    self.Page = [NSNumber numberWithInteger:0];
}

@end
