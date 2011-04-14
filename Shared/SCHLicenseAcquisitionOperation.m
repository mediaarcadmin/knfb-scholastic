//
//  SCHLicenseAcquisitionOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 14/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLicenseAcquisitionOperation.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"

@interface SCHLicenseAcquisitionOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

#pragma mark -

@implementation SCHLicenseAcquisitionOperation

- (void) updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForRightsParsing];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    [self endOperation];
}

- (void) updateBookWithFailure
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    [self endOperation];
}

- (void) beginOperation
{
    NSLog(@"License acquisition goes here - ISBN is available as %@.", self.isbn);
    
    [self updateBookWithSuccess];
}

@end
