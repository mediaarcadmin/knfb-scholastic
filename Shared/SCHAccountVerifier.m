//
//  SCHAccountVerifier.m
//  Scholastic
//
//  Created by John Eddie on 20/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAccountVerifier.h"

#import "SCHScholasticGetUserInfoWebService.h"
#import "SCHUserDefaults.h"

// Constants
NSString * const kSCHAccountVerifierErrorDomain = @"AccountVerifierErrorDomain";
NSInteger const kSCHAccountVerifierSPSIDError = 2000;
NSInteger const kSCHAccountVerifierStoredSPSIDError = 2001;

@interface SCHAccountVerifier ()

@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) SCHScholasticGetUserInfoWebService *scholasticGetUserInfoWebService;
@property (nonatomic, copy) AccountVerifiedBlock accountVerifiedBlock;

@end

@implementation SCHAccountVerifier

@synthesize waitingOnResponse;
@synthesize scholasticGetUserInfoWebService;
@synthesize accountVerifiedBlock;

#pragma mark - Object lifecycle 

- (id)init
{
	self = [super init];
	if (self != nil) {                
        waitingOnResponse = NO;
        
        scholasticGetUserInfoWebService = [[SCHScholasticGetUserInfoWebService alloc] init];
		scholasticGetUserInfoWebService.delegate = self;	        
	}
	return self;
}

- (void)dealloc 
{
    scholasticGetUserInfoWebService.delegate = nil;
    [scholasticGetUserInfoWebService release], scholasticGetUserInfoWebService = nil;    
    [accountVerifiedBlock release], accountVerifiedBlock = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (BOOL)verifyAccount:(NSString *)spsID
 accountVerifiedBlock:(AccountVerifiedBlock)anAccountVerifiedBlock
{
    BOOL ret = NO;
    
    if (self.waitingOnResponse == NO &&
        [[spsID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&        
        anAccountVerifiedBlock != nil) {
        self.accountVerifiedBlock = anAccountVerifiedBlock;
        self.waitingOnResponse = YES;
        [self.scholasticGetUserInfoWebService getUserInfo:spsID];
        ret = YES; 
    }
    
    return ret;
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    if (self.accountVerifiedBlock != nil) {
        NSString *spsID = [result objectForKey:kSCHScholasticGetUserInfoWebServiceSPSID];
        NSString *storedSPSID = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey];
        NSError *error = nil;
        
        if (spsID == nil || spsID == (id)[NSNull null]) {
            error = [NSError errorWithDomain:kSCHAccountVerifierErrorDomain 
                                        code:kSCHAccountVerifierSPSIDError
                                    userInfo:[NSDictionary dictionaryWithObject:@"Failed to verify account, SPS ID was missing"
                                                                         forKey:NSLocalizedDescriptionKey]];
        } else if (storedSPSID == nil) {
            error = [NSError errorWithDomain:kSCHAccountVerifierErrorDomain 
                                        code:kSCHAccountVerifierStoredSPSIDError
                                    userInfo:[NSDictionary dictionaryWithObject:@"Failed to verify account, stored SPS ID (UserKey) was missing"
                                                                         forKey:NSLocalizedDescriptionKey]];        
        }
        
        if (error == nil) {
            BOOL spsIDsAreEqual = [spsID isEqualToString:storedSPSID];
            self.accountVerifiedBlock(spsIDsAreEqual, nil);        
        } else {
            self.accountVerifiedBlock(NO, error);                
        }        
        
        self.accountVerifiedBlock = nil;            
    }
    
    self.waitingOnResponse = NO;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    if (self.accountVerifiedBlock != nil) {
        self.accountVerifiedBlock(NO, error);
        self.accountVerifiedBlock = nil;            
    }
    
    self.waitingOnResponse = NO;    
}

@end
