//
//  BITOperationWithBlocks.h
//  BITOperation
//
//  Created by Neil Gall on 02/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "BITOperation.h"

@interface BITOperationWithBlocks : BITOperation

typedef BOOL (^BITOperationIsCancelledBlock)(void);
typedef void (^BITOperationSuccessBlock)(void);
typedef void (^BITOperationFailedBlock)(NSError *error);
typedef void (^BITOperationTimeoutBlock)(void);
typedef void (^BITOperationFinallyBlock)(void);
typedef void (^BITOperationSyncMainBlock)(BITOperationIsCancelledBlock isCancelled, BITOperationFailedBlock failed);
typedef void (^BITOperationAsyncMainBlock)(BITOperationIsCancelledBlock isCancelled, BITOperationAsyncCompletionBlock completion);

#pragma mark - Block Interface

/**
 * Main block for a synchronous background operation. The block should periodically check
 * isCancelled and return immediately if so. On success the block may simply exit; on failure
 * it should report the error via the BITOperationFailedBlock.
 */
@property (nonatomic, copy) BITOperationSyncMainBlock syncMain;

/**
 * Main block for an asynchronous background operation. The completion parameter will not be nil,
 * and the block must arrange for it to be called when the operation is complete. If the operation
 * has failed, an NSError should be passed to the completion block.
 */
@property (nonatomic, copy) BITOperationAsyncMainBlock asyncMain;

/**
 * Normal case completion block. This is invoked after main or asyncMain completes, unless there is a
 * timeout or exception.
 */
@property (nonatomic, copy) BITOperationSuccessBlock success;

/**
 * Timeout handler. If this is non-nil, timeouts will come here, else they will go to the 'failed'
 * block with an BITOperationTimedOut error code.
 */
@property (nonatomic, copy) BITOperationTimeoutBlock timeout;

/**
 * Error handler. If the syncMain block throws an exception, or the asyncMain block passes an NSError
 * to its completion handler, it will be delivered to this block on the completion queue.
 */
@property (nonatomic, copy) BITOperationFailedBlock failed;

/**
 * Finally block. This is always invoked after success, timeout or catch, or even if the operation is
 * cancelled, and is the ideal place to clean up resources used in the operation.
 */
@property (nonatomic, copy) BITOperationFinallyBlock finally;

@end
