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

- (void)updateBookWithSuccess
{
    if (self.isCancelled) {
        [self endOperation];
		return;
	}

    [self setProcessingState:SCHBookProcessingStateReadyToRead];
    [self setIsProcessing:NO];
    
    [self endOperation];
}

- (void)updateBookWithFailure
{
    [self endOperation];
}

- (void)beginOperation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
#ifndef __OPTIMIZE__    
    // This title is only used for logging
    __block NSString *title = nil;
    [self performWithBook:^(SCHAppBook *book) {
        title = [book.Title copy];
    }];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
#endif
    EucEPubBook *eucBook = [[SCHBookManager sharedBookManager] threadSafeCheckOutEucBookForBookIdentifier:self.identifier];

    if (eucBook) {
        [eucBook generateAndCacheUncachedRecachableData];
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.identifier];
        NSLog(@"Analysis of book %@ took %ld seconds", title, (long)round(CFAbsoluteTimeGetCurrent() - startTime));
        [self updateBookWithSuccess];
    } else {
        NSLog(@"Pagination of book %@ failed. Could not checkout out SCHFlowEucBook", title);
        [self updateBookWithFailure];
    }

#ifndef __OPTIMIZE__
    [title release];
#endif
    
    [pool drain];

}

@end
