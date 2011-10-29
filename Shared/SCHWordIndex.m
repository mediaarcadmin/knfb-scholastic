// 
//  SCHWordIndex.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHWordIndex.h"

#import "SCHLocationText.h"

// Constants
NSString * const kSCHWordIndex = @"SCHWordIndex";

@implementation SCHWordIndex 

@dynamic Start;
@dynamic End;
@dynamic LocationText;

- (void)setInitialValues
{
    self.Start = [NSNumber numberWithInteger:0];
    self.End = [NSNumber numberWithInteger:0];    
}

@end
