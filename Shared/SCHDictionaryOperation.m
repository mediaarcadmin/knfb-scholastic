//
//  SCHDictionaryOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 27/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryOperation.h"

@implementation SCHDictionaryOperation

#pragma mark - Operation Methods

- (void)setNotCancelledCompletionBlock:(void (^)(void))block
{
    __block NSOperation *selfPtr = self;
    
    [self setCompletionBlock:^{
        if (![selfPtr isCancelled]) {
            block();
        }
    }];
}

@end
