//
//  BITOperation.m
//
//  Created by Neil Gall on 01/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "BITOperation.h"

enum BITOperationAsyncState {
    BITOperationReady,
    BITOperationExecuting,
    BITOperationFinished
};

@interface BITOperation ()

@property (nonatomic, assign) enum BITOperationAsyncState asyncState;
@property (nonatomic, assign) BOOL timedOut;
@property (nonatomic, assign) BOOL completedSuccessfully;
@property (nonatomic, assign) BOOL reportedError;
@property (nonatomic, retain) NSMutableArray *successDependencies;
@property (nonatomic, retain) NSMutableArray *failureDependencies;

- (BOOL)shouldRun;
@end

@implementation BITOperation

NSString *const BITOperationErrorDomain = @"BITOperationError";
NSString *const BITOperationExceptionKey = @"exception";

@synthesize permittedExecutionTime;
@synthesize completionQueue;
@synthesize title;
@synthesize asyncState;
@synthesize timedOut;
@synthesize completedSuccessfully;
@synthesize reportedError;
@synthesize successDependencies;
@synthesize failureDependencies;

- (void)dealloc
{
    dispatch_release(completionQueue), completionQueue = NULL;
    [successDependencies release], successDependencies = nil;
    [failureDependencies release], failureDependencies = nil;
    [title release], title = nil;
    [super dealloc];
}

+ (BITOperation *)operation
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init])) {
        self.completionQueue = dispatch_get_current_queue();
        self.permittedExecutionTime = 0;
        self.completedSuccessfully = NO;
        self.asyncState = BITOperationReady;
        self.timedOut = NO;
        self.successDependencies = nil;
        self.failureDependencies = nil;
    }
    return self;
}

- (void)setCompletionQueue:(dispatch_queue_t)newCompletionQueue
{
    if (completionQueue == newCompletionQueue) {
        return;
    }
    if (completionQueue != NULL) {
        dispatch_release(completionQueue);
    }
    completionQueue = newCompletionQueue;
    if (completionQueue != NULL) {
        dispatch_retain(completionQueue);
    }
}

- (void)dispatchSyncToCompletionQueue:(dispatch_block_t)block
{
    if (dispatch_get_current_queue() == self.completionQueue) {
        block();
    } else {
        dispatch_sync(self.completionQueue, block);
    }
}

- (void)setAsyncState:(enum BITOperationAsyncState)state
{
    [self willChangeValueForKey:@"isExecuting"];

    if (state == BITOperationFinished) {
        [self willChangeValueForKey:@"isFinished"];
    }
    
    asyncState = state;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (state == BITOperationFinished) {
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (void)setupTimeoutOnQueue:(dispatch_queue_t)timeoutQueue
{
    if (self.permittedExecutionTime > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.permittedExecutionTime*NSEC_PER_SEC), timeoutQueue, ^{
            if ([self isExecuting]) {
                self.timedOut = YES;
                [super cancel];
            }
        });
    }
}

- (void)runAsynchronously
{
    if (![self shouldRun]) {
        [self cancel];
        self.asyncState = BITOperationFinished;
        return;
    }
    
    self.asyncState = BITOperationExecuting;
    
    BITOperationAsyncCompletionBlock completion = ^(NSError *error) {
        dispatch_async(self.completionQueue, ^{
            if (self.timedOut) {
                [self operationDidTimeout];
            } else if ([self isCancelled]) {
                // do nothing
            } else if (error) {
                [self operationDidFailWithError:error];
            } else {
                self.completedSuccessfully = YES;
                [self operationDidSucceed];
            }
            [self operationFinally];
            self.asyncState = BITOperationFinished;
        });
    };
    
    @try {
        [self setupTimeoutOnQueue:dispatch_get_current_queue()];
        dispatch_async(self.completionQueue, ^{
            [self operationAsyncMainWithCompletion:completion];
        });
    }
    @catch (NSException *exception) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  exception, BITOperationExceptionKey,
                                  [exception description], NSLocalizedDescriptionKey,
                                  nil];
        [self operationDidFailWithError:[NSError errorWithDomain:BITOperationErrorDomain code:BITOperationThrewException userInfo:userInfo]];
    }
}

- (void)runSynchronously
{
    self.reportedError = NO;

    [self operationSyncMain];

    if (!self.reportedError && ![self isCancelled]) {
        self.completedSuccessfully = YES;
    }
    
    [self dispatchSyncToCompletionQueue:^{
        if (!self.reportedError) {
            if (self.timedOut) {
                [self operationDidTimeout];
            } else if (![self isCancelled]) {
                [self operationDidSucceed];
            }
        }
        [self operationFinally];
    }];
}

- (void)start
{
    if ([self isConcurrent]) {
        [self runAsynchronously];
    } else {
        [super start];
    }
}

- (void)main
{    
    if (![self shouldRun]) {
        [self cancel];
        return;
    }
    
    @try {
        [self setupTimeoutOnQueue:self.completionQueue];
        [self runSynchronously];
    }
    @catch (NSException *exception) {
        [self dispatchSyncToCompletionQueue:^{
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      exception, BITOperationExceptionKey,
                                      [exception reason], NSLocalizedDescriptionKey,
                                      nil];
            [self operationDidFailWithError:[NSError errorWithDomain:BITOperationErrorDomain code:BITOperationThrewException userInfo:userInfo]];
            [self operationFinally];
        }];
    }
}

- (BOOL)isExecuting
{
    if ([self isConcurrent]) {
        return self.asyncState == BITOperationExecuting;
    } else {
        return [super isExecuting];
    }
}

- (BOOL)isFinished
{
    if ([self isConcurrent]) {
        return self.asyncState == BITOperationFinished;
    } else {
        return [super isFinished];
    }
}

- (void)cancel
{
    if ([self isConcurrent]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeout) object:nil];
    }
    [super cancel];
}

#pragma mark - Dependencies

- (void)addSuccessDependency:(BITOperation *)operation
{
    NSAssert(![self.failureDependencies containsObject:operation], @"cannot add the same dependency for both success and failure - use addDependency");
    
    [self addDependency:operation];
    
    if (!self.successDependencies) {
        self.successDependencies = [NSMutableArray array];
    }
    [self.successDependencies addObject:operation];
}

- (void)addFailureDependency:(BITOperation *)operation
{
    NSAssert(![self.failureDependencies containsObject:operation], @"cannot add the same dependency for both success and failure - use addDependency");

    [self addDependency:operation];
    
    if (!self.failureDependencies) {
        self.failureDependencies = [NSMutableArray array];
    }
    [self.failureDependencies addObject:operation];
}

- (void)removeDependency:(NSOperation *)operation
{
    [self.successDependencies removeObject:operation];
    [self.failureDependencies removeObject:operation];
    [super removeDependency:operation];
}

- (BOOL)shouldRun
{
    for (BITOperation *operation in self.successDependencies) {
        if ([operation isCancelled] || !operation.completedSuccessfully)
            return NO;
    }
    for (BITOperation *operation in self.failureDependencies) {
        if ([operation isCancelled] || operation.completedSuccessfully) {
            return NO;
        }
    }
    return YES;
}

- (void)operationError:(NSError *)error
{
    self.reportedError = YES;
    [self dispatchSyncToCompletionQueue:^{
        [self operationDidFailWithError:error];
    }];
}

#pragma mark - Subclass interface

- (void)operationAsyncMainWithCompletion:(BITOperationAsyncCompletionBlock)completion
{}

- (void)operationSyncMain
{}

- (void)operationDidSucceed
{}

- (void)operationDidFailWithError:(NSError *)error
{}

- (void)operationDidTimeout
{}

- (void)operationFinally
{}

@end
