//
//  SCHProcessingManager.m
//  Scholastic
//
//  Created by Neil Gall on 28/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProcessingManager.h"

const NSUInteger kSCHProcessingManagerBatchSize = 10;

@implementation SCHProcessingManager

+ (SCHProcessingManager *)sharedProcessingManager
{
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // ignore
}

@end
