//
//  SCHFlowPaginateOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowPaginateOperation.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"

@interface SCHFlowPaginateOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

@implementation SCHFlowPaginateOperation

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
    [self updateBookWithSuccess];
    return;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    SCHFlowEucBook *eucBook = [[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:self.isbn];
    if (eucBook) {
        NSLog(@"Pagination of book %@ took %ld seconds", book.Title, (long)round(CFAbsoluteTimeGetCurrent() - startTime));
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
        [self updateBookWithSuccess];
    } else {
        NSLog(@"Pagination of book %@ failed. Could not checkout out SCHFlowEucBook", book.Title);
        [self updateBookWithFailure];
    }
    
    [pool drain];
}

@end
