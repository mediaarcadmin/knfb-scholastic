//
//  SCHCOPPAManager.m
//  Scholastic
//
//  Created by John Eddie on 20/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHCOPPAManager.h"

#import "SCHAccountValidation.h"
#import "SCHScholasticGetUserInfoWebService.h"
#import "SCHAuthenticationManager.h"
#import "SCHAppStateManager.h"

@interface SCHCOPPAManager ()

@property (nonatomic, retain) SCHAccountValidation *accountValidation;
@property (nonatomic, retain) SCHScholasticGetUserInfoWebService *scholasticWebService;
@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) NSDate *nextRequest;

- (void)releaseResources;

@end

@implementation SCHCOPPAManager

@synthesize accountValidation;
@synthesize scholasticWebService;
@synthesize waitingOnResponse;
@synthesize nextRequest;

#pragma mark - Default Manager Object

+ (SCHCOPPAManager *)sharedCOPPAManager
{
    static dispatch_once_t pred;
    static SCHCOPPAManager *sharedManager = nil;
    
    dispatch_once(&pred, ^{
		sharedManager = [[SCHCOPPAManager alloc] init];        
    });
	
	return sharedManager;
}

#pragma mark - Object lifecycle 

- (id)init 
{
    self = [super init];
    if (self) {
        waitingOnResponse = NO;
        nextRequest = [[NSDate date] retain];
        
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationWillEnterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];	        
    }
    return self;
}

- (void)releaseResources
{
    scholasticWebService.delegate = nil;
    [scholasticWebService release], scholasticWebService = nil;
    
    [accountValidation release], accountValidation = nil;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationWillEnterForegroundNotification 
                                                  object:nil];

    [self releaseResources];
    [nextRequest release], nextRequest = nil;
    
    [super dealloc];
}

#pragma mark - accessor methods

- (SCHScholasticGetUserInfoWebService *)scholasticWebService
{
    if (scholasticWebService == nil) {
        scholasticWebService = [[SCHScholasticGetUserInfoWebService alloc] init];
		scholasticWebService.delegate = self;	
    }
    
    return scholasticWebService;
}

- (SCHAccountValidation *)accountValidation
{
    if (accountValidation == nil) {
        accountValidation = [[SCHAccountValidation alloc] init];
    }
    
    return accountValidation;
}

#pragma mark - methods

- (void)checkCOPPAIfRequired
{    
    if (self.waitingOnResponse == NO &&
        [self.nextRequest earlierDate:[NSDate date]] == self.nextRequest &&        
        [[SCHAppStateManager sharedAppStateManager] canSyncNotes] == NO) {
        SCHCOPPAManager *weakSelf = self;
        self.waitingOnResponse = YES;
        [[SCHAuthenticationManager sharedAuthenticationManager] pTokenWithValidation:^(NSString *pToken, NSError *error) {
            if (error == nil) {
                [weakSelf.scholasticWebService getUserInfo:pToken];     
            } else {
                weakSelf.waitingOnResponse = NO;
            }
        }];
    }
}

- (void)resetCOPPA
{
    [[SCHAppStateManager sharedAppStateManager] setCanSyncNotes:NO];
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    if ([[result objectForKey:kSCHScholasticGetUserInfoWebServiceCOPPA] boolValue] == YES) {
        [[SCHAppStateManager sharedAppStateManager] setCanSyncNotes:YES];
        NSLog(@"COPPA Compliance accepted");
        
        // we won't be using the resources any more so let's release them
        [self releaseResources];
    }
    
    self.nextRequest = [NSDate dateWithTimeIntervalSinceNow:60.0];
    self.waitingOnResponse = NO;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);

    self.nextRequest = [NSDate dateWithTimeIntervalSinceNow:60.0];
    self.waitingOnResponse = NO;    
}

#pragma mark - Notification methods

- (void)applicationWillEnterForeground
{
    [self checkCOPPAIfRequired];
}

@end
