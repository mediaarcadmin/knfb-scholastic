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

@end

#pragma mark -

@implementation SCHLicenseAcquisitionOperation

@synthesize licenseAcquisitionSession;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	[licenseAcquisitionSession release], licenseAcquisitionSession = nil;
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)beginOperation
{ 
    
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] threadSafeCheckOutXPSProviderForBookIdentifier:self.identifier];
    
    if (xpsProvider) {
    
        BOOL useDRM = [xpsProvider isEncrypted];
    
        if (useDRM) {
            [xpsProvider resetDrmDecrypter];
        }
    
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.identifier];
    
        if (useDRM) {
            if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {		
                self.licenseAcquisitionSession = [[[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier] autorelease];
                [self.licenseAcquisitionSession setDelegate:self];            
                [self.licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
                self.licenseAcquisitionSession = nil;
            } else {
                // It's not ideal but rather than changing the license aquisition operation to be async, we use an NSCondition to wait for the authentication to complete
                // We cannot just set the success and failure blocks because those will fire on the main thread and this operation will be orphaned
                
                __block BOOL authenticationSuccess = NO;
                __block BOOL authenticationComplete = NO;
                
                __block NSCondition *authenticationCondition = [[NSCondition alloc] init];
                
                // Attempt to authenticate
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        authenticationSuccess = YES;
                    } else {
                        authenticationSuccess = NO;
                    }
                    
                    [authenticationCondition lock];
                    authenticationComplete = YES;
                    [authenticationCondition signal];
                    [authenticationCondition unlock];
                    
                } failureBlock:^(NSError *error) {
                    authenticationSuccess = NO;
                    
                    [authenticationCondition lock];
                    authenticationComplete = YES;
                    [authenticationCondition signal];
                    [authenticationCondition unlock];
                    
                } waitUntilVersionCheckIsDone:YES];
                
                [authenticationCondition lock];
                while (!authenticationComplete) {
                    [authenticationCondition wait];
                }
                [authenticationCondition unlock];
                
                if (authenticationSuccess) {
                    self.licenseAcquisitionSession = [[[SCHDrmLicenseAcquisitionSession alloc] initWithBook:self.identifier] autorelease];
                    [self.licenseAcquisitionSession setDelegate:self];            
                    [self.licenseAcquisitionSession acquireLicense:[[SCHAuthenticationManager sharedAuthenticationManager] aToken] bookID:self.identifier];
                    self.licenseAcquisitionSession = nil;
                } else {
                    [self updateBookWithFailure];
                }
                
                [authenticationCondition release];
            }
        } else {
            [self updateBookWithSuccess];
        }
    } else {
        [self updateBookWithFailure];
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
    
    NSLog(@"licenseAcquisitionSession didFailWithError: %@ : %@", error, [error userInfo]);

    [self updateBookWithFailure];
}

@end
