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
    licenseAcquisitionSession = [[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier];
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
    if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
        [licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
    } else {
        [self setIsProcessing:NO];
    }
}

#pragma mark - Book Updates

- (void)updateBookWithSuccess
{
    if (self.isCancelled) {
        [self endOperation];
		return;
	}

    [self setProcessingState:SCHBookProcessingStateReadyForRightsParsing];
    [self setIsProcessing:NO];
    [self endOperation];
}

- (void)updateBookWithFailure
{
    if (self.isCancelled) {
        [self endOperation];
		return;
	}

    [self setProcessingState:SCHBookProcessingStateUnableToAcquireLicense];
    [self setIsProcessing:NO];
    [self endOperation];
}



#pragma mark -
#pragma mark DRM License Acquisition Session Delegate methods

- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didComplete:(id)result
{
    if (self.isCancelled) {
        [self endOperation];
		return;
	}

    [self updateBookWithSuccess];
}

- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didFailWithError:(NSError *)error
{
    if (self.isCancelled) {
        [self endOperation];
		return;
	}

    [self updateBookWithFailure];
}

@end
