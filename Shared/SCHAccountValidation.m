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

@interface SCHAccountValidation ()

@property (nonatomic, copy, readwrite) NSString *pToken;
@property (nonatomic, assign) BOOL waitingOnResponse;
@property (nonatomic, retain) SCHScholasticWebService *scholasticWebService;
@property (nonatomic, copy) ValidateBlock validateBlock;

@end

@implementation SCHAccountValidation

@synthesize pToken;
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
	}
	return(self);
}

- (void)dealloc 
{
    [pToken release], pToken = nil;
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
    
    return(ret);
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
    self.validateBlock(nil, error);
    self.validateBlock = nil;    
    self.waitingOnResponse = NO;    
}

@end
