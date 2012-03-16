//
//  SCHRecommendationWebService.m
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationWebService.h"
#import "SCHRecommendationConstants.h"

#import "SCHUserDefaults.h"
#import "NSString+URLEncoding.h"
#import "BITNetworkActivityManager.h"
#import "SCHRecommendationProcessor.h"

// Constants
NSString * const kSCHRecommendationWebServiceProfileURLString = @"%@profile/recommend.xml?age=%@&unique_id=%@";
NSString * const kSCHRecommendationWebServiceBookURLString = @"%@backofbook/recommend.xml?item=%@&unique_id=%@";
NSString * const kSCHRecommendationWebServiceBookListSeparator = @"|";

NSString * const kSCHRecommendationWebServiceRetrieveRecommendationsForProfile = @"RetrieveRecommendationsForProfile";
NSString * const kSCHRecommendationWebServiceRetrieveRecommendationsForBooks = @"RetrieveRecommendationsForBooks";

NSString * const kSCHRecommendationWebServiceErrorDomain = @"RecommendationWebServiceErrorDomain";
NSInteger const kSCHRecommendationWebServiceParseError = 2000;

@interface SCHRecommendationWebService ()

@property (nonatomic, retain) QHTTPOperation *downloadOperation;

@end

@implementation SCHRecommendationWebService

@synthesize downloadOperation;

- (void)dealloc
{
    downloadOperation.delegate = nil;
    [downloadOperation release], downloadOperation = nil;
    
    [super dealloc];
}

- (void)clear
{
    downloadOperation.delegate = nil;
    [downloadOperation release], downloadOperation = nil;    
}

- (BOOL)retrieveRecommendationsForProfileWithAges:(NSArray *)ages
{
    BOOL ret = NO;
    
    NSString *userKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey];
    
    if (userKey != nil) {
        NSString *urlString = [NSString stringWithFormat:kSCHRecommendationWebServiceProfileURLString, 
                               RECOMMENDATION_SERVER_ENDPOINT,
                               [[ages componentsJoinedByString:kSCHRecommendationWebServiceBookListSeparator] urlEncodeUsingEncoding:NSUTF8StringEncoding],
                               [userKey urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (url != nil) {
            NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
            [acceptableStatusCodes addIndex:206];
            
            self.downloadOperation = [[[QHTTPOperation alloc] initWithURL:url] autorelease];
            self.downloadOperation.acceptableStatusCodes = acceptableStatusCodes;
            self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToMemory];
            self.downloadOperation.delegate = self;
            
            __block SCHRecommendationWebService *weakSelf = self;
            self.downloadOperation.completionBlock = ^{                
                [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
                
                SCHRecommendationProcessor *recommendationProcessor = [[SCHRecommendationProcessor alloc] init];
                NSArray *recommendations = [recommendationProcessor recommendationsFrom:[self.downloadOperation.responseOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
                if (recommendations == nil) {
                    NSError *error = [NSError errorWithDomain:kSCHRecommendationWebServiceErrorDomain 
                                                         code:kSCHRecommendationWebServiceParseError 
                                                     userInfo:[NSDictionary dictionaryWithObject:@"Error while attempting to parse recommend.xml"
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        [(id)self.delegate method:@"" didFailWithError:error
                                      requestInfo:nil 
                                           result:nil];
                    }
                } else {
                    if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                        [(id)self.delegate method:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile didCompleteWithResult:[NSDictionary dictionaryWithObject:recommendations forKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] 
                                         userInfo:nil];									
                    }
                }
                [recommendationProcessor release], recommendationProcessor = nil;
            };
            
            [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
            
            [self.downloadOperation start];
        }
    }
    
    return ret;
}

- (BOOL)retrieveRecommendationsForBooks:(NSArray *)books
{
    BOOL ret = NO;
    
    NSString *userKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUserKey];
    
    if (userKey != nil) {
        NSString *urlString = [NSString stringWithFormat:kSCHRecommendationWebServiceBookURLString, 
                               RECOMMENDATION_SERVER_ENDPOINT,
                               [[books componentsJoinedByString:kSCHRecommendationWebServiceBookListSeparator] urlEncodeUsingEncoding:NSUTF8StringEncoding],
                                [userKey urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (url != nil) {
            NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
            [acceptableStatusCodes addIndex:206];
            
            self.downloadOperation = [[[QHTTPOperation alloc] initWithURL:url] autorelease];
            self.downloadOperation.acceptableStatusCodes = acceptableStatusCodes;
            self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToMemory];
            self.downloadOperation.delegate = self;
            
            __block SCHRecommendationWebService *weakSelf = self;
            self.downloadOperation.completionBlock = ^{                
                [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
                
                SCHRecommendationProcessor *recommendationProcessor = [[SCHRecommendationProcessor alloc] init];
                NSArray *recommendations = [recommendationProcessor recommendationsFrom:[self.downloadOperation.responseOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
                if (recommendations == nil) {
                    NSError *error = [NSError errorWithDomain:kSCHRecommendationWebServiceErrorDomain 
                                                         code:kSCHRecommendationWebServiceParseError 
                                                     userInfo:[NSDictionary dictionaryWithObject:@"Error while attempting to parse recommend.xml"
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        [(id)self.delegate method:@"" didFailWithError:error
                                      requestInfo:nil 
                                           result:nil];
                    }
                } else {
                    if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                        [(id)self.delegate method:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks didCompleteWithResult:[NSDictionary dictionaryWithObject:recommendations forKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] 
                                         userInfo:nil];									
                    }
                }
                [recommendationProcessor release], recommendationProcessor = nil;
            };
            
            [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
            
            [self.downloadOperation start];
        }
    }
    
    return ret;
}

#pragma mark - QHTTPOperationDelegate methods
- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    // nop
}

- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize
{
    // nop
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    
    if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
        [(id)self.delegate method:@"" didFailWithError:error
                      requestInfo:nil 
                           result:nil];
    }
}

@end
