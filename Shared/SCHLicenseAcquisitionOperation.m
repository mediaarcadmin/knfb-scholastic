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
#import "SCHXPSProvider.h"

@interface SCHLicenseAcquisitionOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@property (nonatomic, assign) NSNumber *useDRM;

@end

#pragma mark -

@implementation SCHLicenseAcquisitionOperation

@synthesize licenseAcquisitionSession;

#pragma mark - Object Lifecycle

@synthesize useDRM;

- (void)dealloc 
{
	self.licenseAcquisitionSession = nil;
    [useDRM release], useDRM = nil;
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)start
{
    if ([[self useDRM] boolValue] == YES) {
        licenseAcquisitionSession = [[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier];
        [licenseAcquisitionSession setDelegate:self];
    }
    [super start];
}

- (void)beginOperation
{ 
    if ([[self useDRM] boolValue] == YES) {
        if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
            [licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
        } else {
            [self setIsProcessing:NO];
        }
    } else {
        [self updateBookWithSuccess];
    }
}

- (NSNumber *)useDRM
{
    if (useDRM == nil) {
        SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] threadSafeCheckOutXPSProviderForBookIdentifier:self.identifier];
        
        useDRM = [[NSNumber numberWithBool:[xpsProvider isEncrypted]] retain];
        
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.identifier];
    }
    
    return useDRM;
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
