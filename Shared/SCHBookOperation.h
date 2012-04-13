//
//  SCHBookOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHProcessingManager.h"
#import "SCHCoreDataOperation.h"

@class NSManagedObjectContext;
@class SCHAppBook;
@class SCHBookIdentifier;

@interface SCHBookOperation : SCHCoreDataOperation 
{
}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;

- (void)beginOperation;
- (void)endOperation;
- (void)setIdentifierWithoutUpdatingProcessingStatus:(SCHBookIdentifier *)newIdentifier;

// thread-safe access to book object; the block is executed synchronously so may make
// changes to any __block storage locals
- (void)performWithBook:(void (^)(SCHAppBook *book))block;

// thread-safe access to book object followed by save; the block is executed asynchronously
- (void)performWithBookAndSave:(void (^)(SCHAppBook *))block;

// thread-safe update of book state
- (void)setProcessingState:(SCHBookCurrentProcessingState)state;

// thread-safe access to book state
- (SCHBookCurrentProcessingState)processingState;

// thread-safe setter for book Processing flag
- (void)setIsProcessing:(BOOL)isProcessing;
- (void)setNotCancelledCompletionBlock:(void (^)(void))block;

- (void)setCoverURLExpiredState;
- (void)resetCoverURLExpiredState;

@end
