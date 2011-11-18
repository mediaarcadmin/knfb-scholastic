//
//  SCHLicenseAcquisitionOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 14/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLicenseAcquisitionOperation.h"
#import "SCHBookManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHXPSProvider.h"

@interface SCHLicenseAcquisitionOperation ()

- (void)updateBookWithSuccess;
- (void)updateBookWithFailure;

@property (nonatomic, retain) NSNumber *useDRM;

@end

#pragma mark -

@implementation SCHLicenseAcquisitionOperation

@synthesize licenseAcquisitionSession;
@synthesize useDRM;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	[licenseAcquisitionSession release], licenseAcquisitionSession = nil;
    [useDRM release], useDRM = nil;
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)beginOperation
{ 
    if ([self.useDRM boolValue] == YES) {
        if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
            self.licenseAcquisitionSession = [[[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier] autorelease];
            [self.licenseAcquisitionSession setDelegate:self];            
            [self.licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
            self.licenseAcquisitionSession = nil;
        } else {
            [self setIsProcessing:NO];
            [self endOperation];
        }
    } else {
        [self updateBookWithSuccess];
    }
}

#pragma mark - Accessor methods

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

#pragma mark - DRM License Acquisition Session Delegate methods

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
