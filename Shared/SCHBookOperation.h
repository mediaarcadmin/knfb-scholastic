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

@interface SCHBookOperation : SCHCoreDataOperation {}

@property (nonatomic, copy) NSString *isbn;
@property BOOL executing;
@property BOOL finished;

- (void) beginOperation;
- (void) endOperation;
- (void) setIsbnWithoutUpdatingProcessingStatus: (NSString *) newIsbn;

// thread-safe access to book object; the block is executed synchronously so may make
// changes to any __block storage locals
- (void)withBook:(NSString *)isbn perform:(void (^)(SCHAppBook *book))block;

// thread-safe access to book object followed by save; the block is executed asynchronously
- (void)withBook:(NSString *)isbn performAndSave:(void (^)(SCHAppBook *))block;

// thread-safe update of book state
- (void)setProcessingState:(SCHBookCurrentProcessingState)state forBook:(NSString *)isbn;

// thread-safe access to book state
- (SCHBookCurrentProcessingState)processingStateForBook:(NSString *)isbn;

// thread-safe setter for book Processing flag
- (void)setBook:(NSString *)isbn isProcessing:(BOOL)isProcessing;

@end
