//
//  SCHDownloadReportingOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 28/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHDownloadReportingOperation.h"
#import "SCHAuthenticationManager.h"
#import "SCHLibreAccessActivityLogWebService.h"
#import "SCHUserDefaults.h"
#import "SCHBookIdentifier.h"
#import <sys/sysctl.h>
#import "SCHAppStateManager.h"

@interface SCHDownloadReportingOperation () <BITAPIProxyDelegate>

@property (nonatomic, retain) SCHLibreAccessActivityLogWebService *activityLogWebService;

- (void)updateBookAfterUnsuccessfulReport;
- (void)updateBookAfterSuccessfulReport;

@end

#pragma mark -

@implementation SCHDownloadReportingOperation

@synthesize activityLogWebService;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [activityLogWebService setDelegate:nil];
    [activityLogWebService release], activityLogWebService = nil;
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)beginOperation
{
    // The web service methods must be called from the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
        
    self.executing = YES;
    self.finished = NO;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        [self updateBookAfterUnsuccessfulReport];
    } else {
        [[SCHAuthenticationManager sharedAuthenticationManager] expireToken];
        if ([SCHAuthenticationManager sharedAuthenticationManager].isAuthenticated == YES) {
            [self saveActivityLog];
        } else {
            
            // Attempt to authenticate
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self saveActivityLog];
                } else {
                    [self updateBookAfterUnsuccessfulReport];
                }
                
            } failureBlock:^(NSError *error) {
                
                [self updateBookAfterUnsuccessfulReport];
                
            } waitUntilVersionCheckIsDone:YES];
            
        }
    }
}

- (void)endOperation
{
    // Always dispatch async the end operation to the main queue so we give the activityLogWebService a chance to complete the run loop
    dispatch_async(dispatch_get_main_queue(), ^{
        [super endOperation];
    });
}

- (void)saveActivityLog
{
    if (self.isCancelled) {
        [self endOperation];
        return;
    }
    
    NSString *userKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey];
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:machine];
    free(machine);
    
    NSString *platform = [NSString stringWithFormat:@"iOS %@ %@ %@", [[UIDevice currentDevice] model], hardware, [[UIDevice currentDevice] systemVersion]];
    
    NSMutableDictionary *devicePlatformItem = [NSMutableDictionary dictionary];
    [devicePlatformItem setValue:@"Device Platform" forKey:kSCHLibreAccessActivityLogWebServiceDefinitionName];
    [devicePlatformItem setValue:platform forKey:kSCHLibreAccessActivityLogWebServiceValue];
    
    NSMutableDictionary *contentIdentifierItem = [NSMutableDictionary dictionary];
    [contentIdentifierItem setValue:@"Content Identifier" forKey:kSCHLibreAccessActivityLogWebServiceDefinitionName];
    [contentIdentifierItem setValue:self.identifier.isbn forKey:kSCHLibreAccessActivityLogWebServiceValue];
    
    NSMutableDictionary *logList = [NSMutableDictionary dictionary];
    [logList setValue:@"eBooks Downloads" forKey:kSCHLibreAccessActivityLogWebServiceActivityName];
    [logList setValue:@"0" forKey:kSCHLibreAccessActivityLogWebServiceCorrelationID];
    [logList setValue:[NSArray arrayWithObjects:devicePlatformItem, contentIdentifierItem, nil]  forKey:kSCHLibreAccessActivityLogWebServiceLogItem];
    [self.activityLogWebService saveActivityLog:[NSArray arrayWithObject:logList] forUserKey:userKey];

}

- (void)cancel
{
    // Detach ourselves as the delegate and cancel
    [self.activityLogWebService setDelegate:nil];
    [super cancel];
}

- (SCHLibreAccessActivityLogWebService *)activityLogWebService
{
    if (activityLogWebService == nil) {
        activityLogWebService = [[SCHLibreAccessActivityLogWebService alloc] init];
		activityLogWebService.delegate = self;
    }
    
    return activityLogWebService;
}

#pragma mark - Book Updates

- (void)updateBookAfterUnsuccessfulReport
{
    if (self.isCancelled) {
        [self endOperation];
        return;
    }
    
    [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
    [self setIsProcessing:NO];
    [self endOperation];
}

- (void)updateBookAfterSuccessfulReport
{
    if (self.isCancelled) {
        [self endOperation];
        return;
    }
    
    // N.B. This is deliberate - we don't want to go into an error state if we can't report the download.
    [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
    [self setIsProcessing:NO];
    [self endOperation];
}

#pragma mark - BITAPIProxyDelegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    NSLog(@"%@:didSucceed\n%@", method, result);
    [self updateBookAfterSuccessfulReport];
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    [self updateBookAfterUnsuccessfulReport];   
}

@end
