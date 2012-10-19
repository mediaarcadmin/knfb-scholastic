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
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHAppRecommendationItem.h"
#import "SCHContentItem.h"
#import "SCHISBNItemObject.h"
#import "SCHMakeNullNil.h"

// Constants
NSString * const kSCHURLManagerSuccess = @"URLManagerSuccess";
NSString * const kSCHURLManagerFailure = @"URLManagerFailure";
NSString * const kSCHURLManagerBatchComplete = @"URLManagerBatchComplete";
NSString * const kSCHURLManagerCleared = @"URLManagerCleared";
static NSUInteger const kSCHURLManagerMaxConnections = 6;
static NSString * const kURLManagerBookIdentifier = @"URLManagerBookIdentifier";
static NSString * const kURLManagerVersion = @"URLManagerVersion";

@interface SCHURLManager ()

- (void)requestURLForBookOnMainThread:(NSDictionary *)parameters;
- (void)requestURLForBooksOnMainThread:(NSDictionary *)arrayOfBooks;
- (SCHISBNItemObject *)ISBNItemObjectForBook:(SCHBookIdentifier *)bookIdentifier
                                     version:(NSNumber *)version;
- (void)requestURLForRecommendationOnMainThread:(NSString *)isbn;
- (void)requestURLForRecommendationsOnMainThread:(NSArray *)arrayOfISBNs;
- (SCHISBNItemObject *)ISBNItemObjectForRecommendation:(NSString *)isbn;
- (void)clearOnMainThread;
- (void)shakeTable;
- (NSDictionary *)processBatchResultOfContentMetadataItems:(NSArray *)contentMetadataItems;
- (BOOL)isValidContentMetadataItemDictionary:(NSDictionary *)contentMetadataItem;
- (void)endBackgroundTask;

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
                  version:(NSNumber *)version
{
    NSParameterAssert(bookIdentifier);
    NSParameterAssert(version);

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:bookIdentifier, kURLManagerBookIdentifier,
                                version, kURLManagerVersion,
                                nil];

    [self performSelectorOnMainThread:@selector(requestURLForBookOnMainThread:) withObject:parameters waitUntilDone:NO];
}

- (void)requestURLForBooks:(NSArray *)arrayOfBooks
{
    NSParameterAssert(arrayOfBooks);

    [self performSelectorOnMainThread:@selector(requestURLForBooksOnMainThread:)
                           withObject:arrayOfBooks
                        waitUntilDone:NO];
}

- (void)requestURLForRecommendation:(NSString *)isbn
{
    NSParameterAssert(isbn);
    
    [self performSelectorOnMainThread:@selector(requestURLForRecommendationOnMainThread:) withObject:isbn waitUntilDone:NO];
}

- (void)requestURLForRecommendations:(NSArray *)arrayOfISBNs
{
    NSParameterAssert(arrayOfISBNs);

    [self performSelectorOnMainThread:@selector(requestURLForRecommendationsOnMainThread:)
                           withObject:arrayOfISBNs
                        waitUntilDone:NO];
}

- (void)clear
{
    [self performSelectorOnMainThread:@selector(clearOnMainThread) withObject:nil waitUntilDone:NO];    
}

#pragma mark - Private methods

- (void)requestURLForBookOnMainThread:(NSDictionary *)parameters
{
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:requestURLForBookOnMainThread MUST be executed on the main thread");

    SCHBookIdentifier *bookIdentifier = [parameters objectForKey:kURLManagerBookIdentifier];
    NSNumber *version = [parameters objectForKey:kURLManagerVersion];

	if (bookIdentifier != nil) {
        SCHISBNItemObject *isbnItem = [self ISBNItemObjectForBook:bookIdentifier
                                                          version:version];
        if (isbnItem != nil) {
            [self.table addObject:[NSArray arrayWithObject:isbnItem]];
        }
		[self shakeTable];
	}
}

- (void)requestURLForBooksOnMainThread:(NSDictionary *)arrayOfBooks
{
    NSAssert([NSThread isMainThread] == YES, @"requestURLForBooksOnMainThread MUST be executed on the main thread");

    if ([arrayOfBooks count] > 0) {
        NSMutableArray *arrayOfISBNItems = [NSMutableArray arrayWithCapacity:[arrayOfBooks count]];

        for (NSDictionary *book in arrayOfBooks) {
            SCHBookIdentifier *bookIdentifier = [book objectForKey:kURLManagerBookIdentifier];
            NSNumber *version = [book objectForKey:kURLManagerVersion];

            if (bookIdentifier != nil) {
                SCHISBNItemObject *isbnItem = [self ISBNItemObjectForBook:bookIdentifier
                                                                  version:version];

                if (isbnItem != nil) {
                    [arrayOfISBNItems addObject:isbnItem];
                }
            }
        }
        [self.table addObject:[NSArray arrayWithArray:arrayOfISBNItems]];
        [self shakeTable];
    }
}

- (SCHISBNItemObject *)ISBNItemObjectForBook:(SCHBookIdentifier *)bookIdentifier
                                     version:(NSNumber *)version
{
    SCHISBNItemObject *ret = nil;

    if (bookIdentifier != nil) {
        ret = [[[SCHISBNItemObject alloc] init] autorelease];
        
        ret.ContentIdentifier = bookIdentifier.isbn;
        ret.ContentIdentifierType = [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
        ret.DRMQualifier = bookIdentifier.DRMQualifier;
        ret.coverURLOnly = NO;
        ret.Version = version;
    }
    
    return ret;
}

- (void)requestURLForRecommendationOnMainThread:(NSString *)isbn
{	
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:requestURLForRecommendationOnMainThread MUST be executed on the main thread");
    
    if (isbn != nil) {
        SCHISBNItemObject *isbnItem = [self ISBNItemObjectForRecommendation:isbn];
        
        if (isbnItem != nil) {
            [self.table addObject:[NSArray arrayWithObject:isbnItem]];
        }
        
		[self shakeTable];
	}
}

- (void)requestURLForRecommendationsOnMainThread:(NSArray *)arrayOfISBNs
{
    NSAssert([NSThread isMainThread] == YES, @"requestURLForRecommendationsOnMainThread MUST be executed on the main thread");

    if ([arrayOfISBNs count] > 0) {
        NSMutableArray *arrayOfISBNItems = [NSMutableArray arrayWithCapacity:[arrayOfISBNs count]];

        for (NSString *isbn in arrayOfISBNs) {
            SCHISBNItemObject *isbnItem = [self ISBNItemObjectForRecommendation:isbn];

            if (isbnItem != nil) {
                [self.table addObject:[NSArray arrayWithObject:isbnItem]];
            }
        }
        [self.table addObject:[NSArray arrayWithObject:arrayOfISBNItems]];
		[self shakeTable];
	}
}

- (SCHISBNItemObject *)ISBNItemObjectForRecommendation:(NSString *)isbn
{
    SCHISBNItemObject *ret = nil;

    if (isbn != nil) {
        ret = [[[SCHISBNItemObject alloc] init] autorelease];
        
        ret.ContentIdentifier = isbn;
        ret.ContentIdentifierType = [NSNumber numberWithInt:kSCHContentItemContentIdentifierTypesISBN13];
        ret.DRMQualifier = [NSNumber numberWithInt:kSCHDRMQualifiersFullWithDRM];
        ret.coverURLOnly = YES;
        ret.Version = [NSNumber numberWithInteger:0];
    }

    return ret;
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
	if ([self.table count] > 0) {
		NSMutableSet *removeFromTable = [NSMutableSet set];
		
        if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
                    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
                }
            }];
        }

		for (NSArray *isbnItems in self.table) {
            // limit the amount of requests
            if (requestCount > kSCHURLManagerMaxConnections) {
                NSLog(@"URL Manager connections maxed out, please wait...");
                continue;
            } else {
                NSLog(@"URL Manager active connections %d", requestCount);
            }

            // find out if any of the items require more than just the cover URL
            BOOL coverURLOnly = YES;
            for (SCHISBNItemObject *item in isbnItems) {
                if (item.coverURLOnly == NO) {
                    coverURLOnly = NO;
                    break;
                }
            }

            if ([self.libreAccessWebService listContentMetadata:isbnItems
                                                    includeURLs:YES coverURLOnly:coverURLOnly] == YES) {
                NSLog(@"Requesting URLs for %@", isbnItems);

                requestCount++;
                [removeFromTable addObject:isbnItems];
            } else {

                [self endBackgroundTask];

                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                        [self shakeTable];
                    }
                } failureBlock:nil];
                break;
            }
        }

        [self.table minusSet:removeFromTable];
    }
}

#pragma mark - BIT API Proxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
	requestCount--;
	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
        NSInteger listCount = [list count];
        
		if (listCount == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess
																object:self userInfo:[list objectAtIndex:0]];
		} else if (listCount > 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerBatchComplete
																object:self
                                                              userInfo:[self processBatchResultOfContentMetadataItems:list]];
        }
	}
	
    [self endBackgroundTask];
    
    [self shakeTable];
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
	requestCount--;
	
    NSArray *list = [requestInfo objectForKey:kSCHLibreAccessWebServiceListContentMetadata];
    NSInteger listCount = [list count];

    if (listCount == 1) {
        SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:[list objectAtIndex:0]] autorelease];
        NSLog(@"Failed URLs for %@", bookIdentifier);

        if (bookIdentifier != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
                                                                object:self 
                                                              userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:bookIdentifier, bookIdentifier.isbn, [NSNumber numberWithInt:[error code]], nil]                                                                                                  forKeys:[NSArray arrayWithObjects:kSCHBookIdentifierBookIdentifier, kSCHAppRecommendationItemIsbn, kSCHAppRecommendationItemErrorCode, nil]]];
        }
    } else if (listCount > 1) {
        SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:[list objectAtIndex:0]] autorelease];
        NSLog(@"Failed URLs for %@", bookIdentifier);

        if (bookIdentifier != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerBatchComplete
                                                                object:self
                                                              userInfo:[self processBatchResultOfContentMetadataItems:list]];

            // add error code
        }
    }
    
    [self endBackgroundTask];
	
    [self shakeTable];
}

- (NSDictionary *)processBatchResultOfContentMetadataItems:(NSArray *)contentMetadataItems
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSMutableArray *successList = [NSMutableArray array];
    NSMutableArray *failureList = [NSMutableArray array];    

    for (NSDictionary *contentMetadataItem in contentMetadataItems) {
        if ([self isValidContentMetadataItemDictionary:contentMetadataItem] == YES) {
            [successList addObject:contentMetadataItem];
        } else {
            SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:contentMetadataItem] autorelease];
            NSLog(@"Failed URLs for %@", bookIdentifier);

            [failureList addObject:bookIdentifier];
        }
    }

    [ret setObject:successList forKey:kSCHURLManagerSuccess];
    [ret setObject:failureList forKey:kSCHURLManagerFailure];

    return [NSDictionary dictionaryWithDictionary:ret];
}

- (BOOL)isValidContentMetadataItemDictionary:(NSDictionary *)contentMetadataItem
{
    BOOL ret = NO;

    if (contentMetadataItem != nil) {
        NSString *contentIdentifier = makeNullNil([contentMetadataItem objectForKey:kSCHLibreAccessWebServiceContentIdentifier]);
        
        if ([[contentIdentifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            ret = YES;
        }
    }

    return ret;
}

- (void)endBackgroundTask
{
    if (requestCount < 1 && 
        self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
    }	
}

@end
