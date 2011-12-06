//
//  SCHDictionaryOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 27/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryOperation.h"

@implementation SCHDictionaryOperation

@synthesize notCancelledCompletionBlock;

- (void)dealloc
{
    Block_release(notCancelledCompletionBlock), notCancelledCompletionBlock = nil;
    [super dealloc];
}

#pragma mark - Operation Methods

- (void)setNotCancelledCompletionBlock:(dispatch_block_t)block
{
    __block NSOperation *selfPtr = self;

    Block_release(notCancelledCompletionBlock);
    
    if (block == nil) {
        notCancelledCompletionBlock = nil;
        self.completionBlock = nil;
    } else {
        notCancelledCompletionBlock = Block_copy(block);
        
        __block dispatch_block_t blockPtr = notCancelledCompletionBlock;
        
        self.completionBlock = ^{
            if (![selfPtr isCancelled]) {
                blockPtr();
            }
        };
    }
}

@end
