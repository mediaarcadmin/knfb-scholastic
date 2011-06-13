//
//  SCHFlowPaginateOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowAnalysisOperation.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"

@interface SCHFlowAnalysisOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

@implementation SCHFlowAnalysisOperation

- (void) updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyToRead];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    
    [self endOperation];
}

- (void) updateBookWithFailure
{
    [self endOperation];
}

- (void) beginOperation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
#ifndef __OPTIMIZE__    
    // This book is only used for logging
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];  
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
#endif
    SCHFlowEucBook *eucBook = [[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:self.isbn];

    if (eucBook) {
        [eucBook generateAndCacheUncachedRecachableData];
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
        NSLog(@"Analysis of book %@ took %ld seconds", book.Title, (long)round(CFAbsoluteTimeGetCurrent() - startTime));
        [self updateBookWithSuccess];
    } else {
        NSLog(@"Pagination of book %@ failed. Could not checkout out SCHFlowEucBook", book.Title);
        [self updateBookWithFailure];
    }
    
    [pool drain];
}

@end
