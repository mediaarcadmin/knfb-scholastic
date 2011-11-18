//
//  SCHAccountValidation.m
//  Scholastic
//
//  Created by John Eddie on 17/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAccountValidation.h"

#import "SCHScholasticWebService.h"

// Constants
NSString * const kSCHAccountValidationErrorDomain = @"AccountValidationErrorDomain";
NSInteger const kSCHAccountValidationPTokenError = 2000;
NSInteger const kSCHAccountValidationCredentialsError = 200;

@interface SCHAccountValidation ()

@property (nonatomic, copy, readwrite) NSString *pToken;
@property (nonatomic, retain) NSDate *pTokenRequested;
@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) SCHScholasticWebService *scholasticWebService;
@property (nonatomic, copy) ValidateBlock validateBlock;

@end

@implementation SCHAccountValidation

@synthesize pToken;
@synthesize pTokenRequested;
@synthesize waitingOnResponse;
@synthesize scholasticWebService;
@synthesize validateBlock;

#pragma mark - Object lifecycle 

- (id)init
{
	self = [super init];
	if (self != nil) {
        pToken = nil;
		waitingOnResponse = NO;

		scholasticWebService = [[SCHScholasticWebService alloc] init];
		scholasticWebService.delegate = self;	
        
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(applicationDidEnterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			        
	}
	return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];

    [pToken release], pToken = nil;
    [pTokenRequested release], pTokenRequested = nil;
    scholasticWebService.delegate = nil;
    [scholasticWebService release], scholasticWebService = nil;
    [validateBlock release], validateBlock = nil;
    
    [super dealloc];
}

#pragma mark - methods

- (BOOL)validateWithUserName:(NSString *)username 
                withPassword:(NSString *)password 
               validateBlock:(ValidateBlock)aValidateBlock
{
    BOOL ret = NO;
    
    if (self.waitingOnResponse == NO && username != nil && password != nil && 
        aValidateBlock != nil) {
        self.pToken = nil;
        self.validateBlock = aValidateBlock;
        self.waitingOnResponse = YES;
        [self.scholasticWebService authenticateUserName:username withPassword:password]; 
        ret = YES; 
    }
    
    return ret;
}

#pragma mark - Accessor methods

- (void)setPToken:(NSString *)aPToken
{
    if (pToken != aPToken) {
        [pToken release];
        pToken = [aPToken copy];
        self.pTokenRequested = (pToken == nil ? nil : [NSDate dateWithTimeIntervalSinceNow:360.0]);
    }
}

- (NSString *)pToken
{
    if (pToken != nil && 
        [self.pTokenRequested earlierDate:[NSDate date]] == self.pTokenRequested) {
        self.pToken = nil;
    }
    
    return pToken;
}

#pragma mark - Notification methods

- (void)applicationDidEnterBackground
{
    self.pToken = nil;
}

#pragma mark - BITAPIProxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{
    id pTokenResponse = [result objectForKey:kSCHScholasticWebServicePToken];
    NSError *error = nil;
    
    if (pTokenResponse == [NSNull null]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Failed to validate account, pToken was missing"
                                                             forKey:NSLocalizedDescriptionKey];		
        
        error = [NSError errorWithDomain:kSCHAccountValidationErrorDomain 
                                     code:kSCHAccountValidationPTokenError
                                 userInfo:userInfo];
    } else {
        self.pToken = pTokenResponse;
    }
    
    self.validateBlock(self.pToken, error);  
    self.validateBlock = nil;    
    self.waitingOnResponse = NO;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    self.validateBlock(nil, error);
    self.validateBlock = nil;    
    self.waitingOnResponse = NO;    
}

@end
