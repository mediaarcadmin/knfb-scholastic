//
//  BITOperationWithBlocks.m
//  BITOperation
//
//  Created by Neil Gall on 02/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "BITOperationWithBlocks.h"

@implementation BITOperationWithBlocks

@synthesize syncMain;
@synthesize asyncMain;
@synthesize success;
@synthesize timeout;
@synthesize failed;
@synthesize finally;

- (void)dealloc
{
    [syncMain release], syncMain = nil;
    [asyncMain release], asyncMain = nil;
    [success release], success = nil;
    [timeout release], timeout = nil;
    [failed release], failed = nil;
    [finally release], finally = nil;
    [super dealloc];
}

- (BOOL)isConcurrent
{
    return self.asyncMain != nil;
}

- (void)operationAsyncMainWithCompletion:(BITOperationAsyncCompletionBlock)completion
{
    BITOperationIsCancelledBlock cancelled = ^BOOL {
        return [self isCancelled];
    };
    
    if (self.asyncMain) {
        self.asyncMain(cancelled, completion);
    }
}

- (void)operationSyncMain
{
    BITOperationIsCancelledBlock isCancelledBlock = ^BOOL {
        return [self isCancelled];
    };
    
    BITOperationFailedBlock failedBlock = ^(NSError *error) {
        [self operationError:error];
    };
    
    if (self.syncMain) {
        self.syncMain(isCancelledBlock, failedBlock);
    }
}

- (void)operationDidSucceed
{
    if (self.success) {
        self.success();
    }
}

- (void)operationDidFailWithError:(NSError *)error
{
    if (self.failed) {
        self.failed(error);
    }
}

- (void)operationDidTimeout
{
    if (self.timeout) {
        self.timeout();
    } else if (self.failed) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"The operation timed out", @"The operation timed out") forKey:NSLocalizedDescriptionKey];
        self.failed([NSError errorWithDomain:BITOperationErrorDomain code:BITOperationTimedOut userInfo:userInfo]);
    }
}

- (void)operationFinally
{
    if (self.finally) {
        self.finally();
    }
}

@end
