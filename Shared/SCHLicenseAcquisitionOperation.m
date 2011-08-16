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
#import "NSNumber+ObjectTypes.h"

@interface SCHLicenseAcquisitionOperation ()

- (BOOL)useDRM;
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
    if ([self useDRM] == YES) {
        licenseAcquisitionSession = [[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier];
        [licenseAcquisitionSession setDelegate:self];
    }
    [super start];
}

- (void)beginOperation
{ 
    if ([self useDRM] == YES) {
        if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
            [licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
        } else {
            [self setIsProcessing:NO];
        }
    } else {
        [self updateBookWithSuccess];
    }
}

- (BOOL)useDRM
{
    __block BOOL useDRM = NO;
    
    [self performWithBook:^(SCHAppBook *book) {
        useDRM = book.ContentMetadataItem.DRMQualifier == [NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullWithDRM];
    }];
    
    return(useDRM);
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

    // remove the downloaded book if it failed DRM to retry later
    [self performWithBook:^(SCHAppBook *book) {
        [book.ContentMetadataItem deleteXPSFile];
    }];    
    
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
