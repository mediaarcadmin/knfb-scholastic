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

@interface SCHFlowPaginateOperation ()

@property (nonatomic, copy) NSString *bookTitle;
@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) BOOL bookCheckedOut;

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

@implementation SCHFlowPaginateOperation

@synthesize bookTitle;
@synthesize startTime;
@synthesize bookCheckedOut;


- (void)dealloc {
     
    if (self.bookCheckedOut) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
    }
    
	[super dealloc];
}

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

}


@end
