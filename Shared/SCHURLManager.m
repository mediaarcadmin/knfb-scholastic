//
//  SCHURLManager.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHURLManager.h"

#import "SCHAuthenticationManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHContentMetadataItem.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHAppRecommendationItem.h"
#import "SCHContentItem.h"
#import "SCHISBNItemObject.h"

// Constants
NSString * const kSCHURLManagerSuccess = @"URLManagerSuccess";
NSString * const kSCHURLManagerFailure = @"URLManagerFailure";
NSString * const kSCHURLManagerCleared = @"URLManagerCleared";
static NSUInteger const kSCHURLManagerMaxConnections = 6;

@interface SCHURLManager ()

- (void)requestURLForBookOnMainThread:(SCHBookIdentifier *)bookIdentifier;
- (void)requestURLForRecommendationOnMainThread:(NSString *)isbn;
- (void)clearOnMainThread;
- (void)shakeTable;

@property (retain, nonatomic) NSMutableSet *table;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (retain, nonatomic) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, assign) NSUInteger requestCount;

@end

/*
 * This class is thread safe in respect to all the exposed methods being
 * wrappers for private methods that are always executed on the MainThread.
 * Notifications are also sent on the Main Thread and should be handled and 
 * propogated to worker threads appropriately.
 */

@implementation SCHURLManager

@synthesize table;
@synthesize backgroundTaskIdentifier;
@synthesize libreAccessWebService;
@synthesize requestCount;

#pragma mark - Singleton Instance methods

+ (SCHURLManager *)sharedURLManager
{
    static dispatch_once_t pred;
    static SCHURLManager *sharedURLManager = nil;
    
    dispatch_once(&pred, ^{
        NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:sharedURLManager MUST be executed on the main thread");
        sharedURLManager = [[super allocWithZone:NULL] init];		
    });
	
    return(sharedURLManager);
}

#pragma mark - methods

- (id)init
{
	self = [super init];
	if (self != nil) {
		table = [[NSMutableSet alloc] init];	
		
		self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;					
		
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
		
		self.requestCount = 0;
	}
	
	return(self);
}

- (void)dealloc
{
	[table release], table = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

	[super dealloc];
}

- (void)requestURLForBook:(SCHBookIdentifier *)bookIdentifier
{
    [self performSelectorOnMainThread:@selector(requestURLForBookOnMainThread:) withObject:bookIdentifier waitUntilDone:NO];
}

- (void)requestURLForRecommendation:(NSString *)isbn
{
    [self performSelectorOnMainThread:@selector(requestURLForRecommendationOnMainThread:) withObject:isbn waitUntilDone:NO];
}
	
- (void)clear
{
    [self performSelectorOnMainThread:@selector(clearOnMainThread) withObject:nil waitUntilDone:NO];    
}

#pragma mark - Private methods

- (void)requestURLForBookOnMainThread:(SCHBookIdentifier *)bookIdentifier
{	
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:requestURLForBookOnMainThread MUST be executed on the main thread");

	if (bookIdentifier != nil) {
        SCHISBNItemObject *isbnItem = [[SCHISBNItemObject alloc] init];
        isbnItem.ContentIdentifier = bookIdentifier.isbn;
        isbnItem.ContentIdentifierType = [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
        isbnItem.DRMQualifier = bookIdentifier.DRMQualifier;
        isbnItem.coverURLOnly = NO;
        
        [self.table addObject:isbnItem];
        
        [isbnItem release];
        
		[self shakeTable];
	}
}

- (void)requestURLForRecommendationOnMainThread:(NSString *)isbn
{	
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:requestURLForRecommendationOnMainThread MUST be executed on the main thread");
    
    if (isbn != nil) {
        SCHISBNItemObject *isbnItem = [[SCHISBNItemObject alloc] init];
        isbnItem.ContentIdentifier = isbn;
        isbnItem.ContentIdentifierType = [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
        isbnItem.DRMQualifier = [NSNumber numberWithInt:kSCHDRMQualifiersFullWithDRM];
        isbnItem.coverURLOnly = YES;
        
        [self.table addObject:isbnItem];
        
        [isbnItem release];
        
		[self shakeTable];
	}
}

- (void)clearOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:clearOnMainThread MUST be executed on the main thread");
	
    [table removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerCleared
                                                        object:self];    
}

- (void)shakeTable
{	
	if ([table count] > 0) {
		NSMutableSet *removeFromTable = [NSMutableSet set];
		
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];            
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		for (id<SCHISBNItem> isbnItem in table) {
            if ([isbnItem conformsToProtocol:@protocol(SCHISBNItem)] == YES) {
                // limit the amount of requests
                if (requestCount > kSCHURLManagerMaxConnections) {
                    NSLog(@"URL Manager connections maxed out, please wait...");
                    continue;
                } else {
                    NSLog(@"URL Manager active connections %d", requestCount);
                }
                
                if ([self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:isbnItem] 
                                                        includeURLs:YES coverURLOnly:[isbnItem coverURLOnly]] == YES) {
                    NSLog(@"Requesting URLs for %@", [isbnItem ContentIdentifier]);
                    
                    requestCount++;
                    [removeFromTable addObject:isbnItem];
                } else {
                    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
                        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
                    }
                    
                    [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                        if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                            [self shakeTable];
                        }
                    } failureBlock:nil];							
                    break;
                }
            }
		}
		
		[table minusSet:removeFromTable];	
	}
}

#pragma mark - BIT API Proxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
	requestCount--;
	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
		
		if ([list count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess 
																object:self userInfo:[list objectAtIndex:0]];
		}		
	}
	
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}	
    
    [self shakeTable];
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
	requestCount--;
	
    NSArray *list = [requestInfo objectForKey:kSCHLibreAccessWebServiceListContentMetadata];
    
    if ([list count] > 0) {
        SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:[list objectAtIndex:0]] autorelease];
        NSLog(@"Failed URLs for %@", bookIdentifier);

        if (bookIdentifier != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:bookIdentifier, bookIdentifier.isbn, [NSNumber numberWithInt:[error code]], nil]                                                                                                  forKeys:[NSArray arrayWithObjects:kSCHBookIdentifierBookIdentifier, kSCHAppRecommendationItemIsbn, kSCHAppRecommendationItemErrorCode, nil]]];	
        }
    }
    
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}	
	
    [self shakeTable];
}

@end
