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

NSInteger const kSCHRecommendationWebServiceMaxRequestItems = 10;

@interface SCHRecommendationWebService ()

@property (nonatomic, retain) QHTTPOperation *profileDownloadOperation;
@property (nonatomic, retain) QHTTPOperation *bookDownloadOperation;
@property (nonatomic, retain) NSString *activeMethod;

@end

@implementation SCHRecommendationWebService

@synthesize profileDownloadOperation;
@synthesize bookDownloadOperation;
@synthesize activeMethod;

- (void)dealloc
{
    profileDownloadOperation.delegate = nil;
    [profileDownloadOperation release], profileDownloadOperation = nil;
    bookDownloadOperation.delegate = nil;
    [bookDownloadOperation release], bookDownloadOperation = nil;    
    [activeMethod release], activeMethod = nil;
    
    [super dealloc];
}

- (void)clear
{
    self.profileDownloadOperation.delegate = nil;
    self.profileDownloadOperation = nil;
    self.bookDownloadOperation.delegate = nil;
    self.bookDownloadOperation = nil;    
    self.activeMethod = nil;
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
        NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
        [acceptableStatusCodes addIndex:206];
        
        self.profileDownloadOperation = [[[QHTTPOperation alloc] initWithURL:url] autorelease];
        self.profileDownloadOperation.acceptableStatusCodes = acceptableStatusCodes;
        self.profileDownloadOperation.responseOutputStream = [NSOutputStream outputStreamToMemory];
        self.profileDownloadOperation.delegate = self;
        
        __block SCHRecommendationWebService *weakSelf = self;
        self.profileDownloadOperation.completionBlock = ^{       
            // completion block always performs, check if an error occursed and thus it's nil
            if (weakSelf.profileDownloadOperation != nil) {
                [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
                NSData *xmlData = [weakSelf.profileDownloadOperation.responseOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                
                SCHRecommendationProcessor *recommendationProcessor = [[SCHRecommendationProcessor alloc] init];
                NSArray *recommendations = [recommendationProcessor recommendationsFrom:xmlData];
                if (recommendations == nil) {
                    NSLog(@"%@", [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease]);
                    NSError *error = [NSError errorWithDomain:kSCHRecommendationWebServiceErrorDomain 
                                                         code:kSCHRecommendationWebServiceParseError 
                                                     userInfo:[NSDictionary dictionaryWithObject:@"Error while attempting to parse recommend.xml"
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    if ([(id)weakSelf.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        NSString *method = [self.activeMethod copy];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            if ([(id)weakSelf.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                                [(id)weakSelf.delegate method:method didFailWithError:error
                                                  requestInfo:nil 
                                                       result:nil];
                            }
                            [method release], activeMethod = nil;
                        });
                    }
                } else {
                    if([(id)weakSelf.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            if([(id)weakSelf.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {                        
                                [(id)weakSelf.delegate method:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile 
                                        didCompleteWithResult:[NSDictionary dictionaryWithObject:recommendations 
                                                                                          forKey:kSCHRecommendationWebServiceRetrieveRecommendationsForProfile] 
                                                     userInfo:nil];									
                            }
                        });
                    }
                }
                [recommendationProcessor release], recommendationProcessor = nil;
                weakSelf.profileDownloadOperation.delegate = nil;
                weakSelf.profileDownloadOperation = nil;            
                weakSelf.activeMethod = nil;
            }
        };
        
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
        [self.profileDownloadOperation start];
        self.activeMethod = kSCHRecommendationWebServiceRetrieveRecommendationsForProfile;
        ret = YES;
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
        NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
        [acceptableStatusCodes addIndex:206];
        
        self.bookDownloadOperation = [[[QHTTPOperation alloc] initWithURL:url] autorelease];
        self.bookDownloadOperation.acceptableStatusCodes = acceptableStatusCodes;
        self.bookDownloadOperation.responseOutputStream = [NSOutputStream outputStreamToMemory];
        self.bookDownloadOperation.delegate = self;
        
        __block SCHRecommendationWebService *weakSelf = self;
        self.bookDownloadOperation.completionBlock = ^{
            // completion block always performs, check if an error occursed and thus it's nil
            if (weakSelf.bookDownloadOperation != nil) {
                [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
                NSData *xmlData = [weakSelf.bookDownloadOperation.responseOutputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                
                SCHRecommendationProcessor *recommendationProcessor = [[SCHRecommendationProcessor alloc] init];
                NSArray *recommendations = [recommendationProcessor recommendationsFrom:xmlData];
                if (recommendations == nil) {
                    NSLog(@"%@", [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease]);                
                    NSError *error = [NSError errorWithDomain:kSCHRecommendationWebServiceErrorDomain 
                                                         code:kSCHRecommendationWebServiceParseError 
                                                     userInfo:[NSDictionary dictionaryWithObject:@"Error while attempting to parse recommend.xml"
                                                                                          forKey:NSLocalizedDescriptionKey]];
                    
                    if ([(id)weakSelf.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                        NSString *method = [self.activeMethod copy];
                        dispatch_async(dispatch_get_main_queue(), ^(void) {                    
                            if ([(id)weakSelf.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {                        
                                [(id)weakSelf.delegate method:method didFailWithError:error
                                                  requestInfo:nil 
                                                       result:nil];
                            }
                            [method release], activeMethod = nil;
                        });
                    }
                } else {
                    if([(id)weakSelf.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            if([(id)weakSelf.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                                [(id)weakSelf.delegate method:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks 
                                        didCompleteWithResult:[NSDictionary dictionaryWithObject:recommendations 
                                                                                          forKey:kSCHRecommendationWebServiceRetrieveRecommendationsForBooks] 
                                                     userInfo:nil];								
                            }
                        });
                    }
                }
                [recommendationProcessor release], recommendationProcessor = nil;
                weakSelf.bookDownloadOperation.delegate = nil;
                weakSelf.bookDownloadOperation = nil;
                weakSelf.activeMethod = nil;
            }
        };
        
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
        [self.bookDownloadOperation start];
        self.activeMethod = kSCHRecommendationWebServiceRetrieveRecommendationsForBooks;
        ret = YES;
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
        [(id)self.delegate method:self.activeMethod didFailWithError:error
                      requestInfo:nil 
                           result:nil];
    }
    
    operation.delegate = nil;
    if (self.profileDownloadOperation == operation) {
        self.profileDownloadOperation = nil;        
    } else if (self.bookDownloadOperation == operation) {
        self.bookDownloadOperation = nil;                
    }
    self.activeMethod = nil;
}

@end
