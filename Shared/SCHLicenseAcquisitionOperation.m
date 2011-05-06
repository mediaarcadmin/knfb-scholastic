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
#import "SCHAuthenticationManager.h"

@interface SCHLicenseAcquisitionOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

#pragma mark -

@implementation SCHLicenseAcquisitionOperation

@synthesize licenseAcquisitionSession;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	self.licenseAcquisitionSession = nil;
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)start
{
#if !LOCALDEBUG
    licenseAcquisitionSession = [[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.isbn];
    [licenseAcquisitionSession setDelegate:self];
#endif    
    [super start];
}

- (void)beginOperation
{ 
#if LOCALDEBUG
    [self updateBookWithSuccess];
    return;
#endif
#if NONDRMAUTHENTICATION
    [self updateBookWithSuccess];
    return;
#endif
    [licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.isbn];
}

#pragma mark - Book Updates

- (void)updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForRightsParsing];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    [self endOperation];
}

- (void)updateBookWithFailure
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    [self endOperation];
}



#pragma mark -
#pragma mark DRM License Acquisition Session Delegate methods

- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didComplete:(id)result
{
    [self updateBookWithSuccess];
}

- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didFailWithError:(NSError *)error
{
    [self updateBookWithFailure];
}

@end
