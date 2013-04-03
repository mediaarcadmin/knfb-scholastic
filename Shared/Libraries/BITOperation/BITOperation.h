//
//  BITOperation.h
//
//  Created by Neil Gall on 01/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

enum BITOperationErrorCodes {
    BITOperationThrewException = 100,
    BITOperationTimedOut
};

extern NSString *const BITOperationErrorDomain;
extern NSString *const BITOperationExceptionKey;

/**
 * Generic NSOperation featuring synchronous/asynchronous tasks, cancellation, timeouts and
 * exception handling.
 */
@interface BITOperation : NSOperation

typedef void (^BITOperationAsyncCompletionBlock)(NSError *error);

/**
 * The maximum time the main or asyncMain blocks will be permitted to execute before being automatically
 * cancelled. Defaults to 0 which disables the timeout behaviour.
 */
@property (nonatomic, assign) NSTimeInterval permittedExecutionTime;

/**
 * The dispatch queue for success, timeout and catch blocks. By default this is the queue on which
 * the operation is created.
 */
@property (nonatomic, assign) dispatch_queue_t completionQueue;

/**
 * Title for this operation.
 */
@property (nonatomic, copy) NSString *title;

/**
 * Make a new empty operation
 */
+ (id)operation;

/**
 * Add a dependency on an operation, but only execute this operation if the earlier operation
 * is not cancelled and completes successfully.
 */
- (void)addSuccessDependency:(BITOperation *)operation;

/**
 * Add a dependency on an operation, but only execute this operation if the earlier operation
 * is not cancelled and ends with failure.
 */
- (void)addFailureDependency:(BITOperation *)operation;

/**
 * YES if this operation completed successfully and would have called its 'success' block
 * if defined. NO if the operation has not yet completed or completed with failure.
 */
- (BOOL)completedSuccessfully;

#pragma mark - for use by subclasses

/**
 * Call from operationSyncMain() to set the failed state. This is equivalent to calling the 'failed'
 * block in the block-based syncMain interface.
 */
- (void)operationError:(NSError *)error;

#pragma mark - Subclass interface

/**
 * Entry point for an asynchronous background operation. The completion parameter will not be nil,
 * and the method must arrange for it to be called when the operation is complete. If the operation
 * has failed, an NSError should be passed to the completion block.
 */
- (void)operationAsyncMainWithCompletion:(BITOperationAsyncCompletionBlock)completion;

/**
 * Entry point for a synchronous background operation. The implementation should periodically
 * check -isCancelled and return immediately if so. On success the block may simply exit; failures
 * should be reported by calling -operationError:.
 */
- (void)operationSyncMain;

/**
 * Invoked on the completion queue after successful completion of sync or async main.
 */
- (void)operationDidSucceed;

/**
 * Invoked on the completion queue after failure a sync or async operation main results
 * in an error.
 */
- (void)operationDidFailWithError:(NSError *)error;

/**
 * Invoked on the completion queue if the operation times out. This will only happen if
 * permittedExecutionTime is changed from its default value of 0.
 */
- (void)operationDidTimeout;

/**
 * Invoked on the completion queue after all other callbacks, regardless of whether the
 * operation succeeded, failed, timeed out or was cancelled. An ideal place to clean up 
 * resources used by the operation.
 */
- (void)operationFinally;


@end
