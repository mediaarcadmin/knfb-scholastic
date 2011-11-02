//
//  SCHURLManager.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHURLManager.h"

#import <CoreData/CoreData.h>

#import "SCHAuthenticationManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHContentMetadataItem.h"
#import "SCHUserContentItem.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

// Constants
NSString * const kSCHURLManagerSuccess = @"URLManagerSuccess";
NSString * const kSCHURLManagerFailure = @"URLManagerFailure";
static NSUInteger const kSCHURLManagerMaxConnections = 6;

@interface SCHURLManager ()

- (void)requestURLForBookOnMainThread:(SCHBookIdentifier *)bookIdentifier;
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

@synthesize managedObjectContext;
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) 
													 name:SCHAuthenticationManagerDidSucceedNotification object:nil];					

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) 
													 name:SCHAuthenticationManagerDidFailNotification object:nil];							
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	
	}
	
	return(self);
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [managedObjectContext release], managedObjectContext = nil;
	[table release], table = nil;
	[libreAccessWebService release], libreAccessWebService = nil;

	[super dealloc];
}

- (void)requestURLForBook:(SCHBookIdentifier *)bookIdentifier
{
    [self performSelectorOnMainThread:@selector(requestURLForBookOnMainThread:) withObject:bookIdentifier waitUntilDone:NO];
}
	
- (void)clear
{
    [self performSelectorOnMainThread:@selector(clearOnMainThread) withObject:nil waitUntilDone:NO];    
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

#pragma mark - Private methods

- (void)requestURLForBookOnMainThread:(SCHBookIdentifier *)bookIdentifier
{	
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:requestURLForBookOnMainThread MUST be executed on the main thread");

	if (bookIdentifier != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem 
                                            inManagedObjectContext:self.managedObjectContext]];	
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                    bookIdentifier.isbn, bookIdentifier.DRMQualifier]];
        
		NSArray *book = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
        
        [fetchRequest release], fetchRequest = nil;
		
		if ([book count] > 0) {
			[table addObject:[book objectAtIndex:0]];
			[self shakeTable];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
																object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:bookIdentifier 
                                                                                                   forKey:kSCHBookIdentifierBookIdentifier]];
        }
	}
}

- (void)clearOnMainThread
{
    NSAssert([NSThread isMainThread] == YES, @"SCHURLManager:clearOnMainThread MUST be executed on the main thread");
	
    [table removeAllObjects];
}

- (void)shakeTable
{	
	if ([table count] > 0) {
		NSMutableSet *removeFromTable = [NSMutableSet set];
		
		self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
		}];
		
		for (SCHContentMetadataItem *contentMetaDataItem in table) {
            // limit the amount of requests
            if (requestCount > kSCHURLManagerMaxConnections) {
                NSLog(@"URL Manager connections maxed out, please wait...");
                continue;
            } else {
                NSLog(@"URL Manager active connections %d", requestCount);
            }

			if ([self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:contentMetaDataItem] 
													includeURLs:YES] == YES) {
				NSLog(@"Requesting URLs for %@", contentMetaDataItem.bookIdentifier);
				
				requestCount++;
				[removeFromTable addObject:contentMetaDataItem];
			} else {
				if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
					[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
					self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
				}
				
				[[SCHAuthenticationManager sharedAuthenticationManager] authenticate];							
				break;
			}
		}
		
		[table minusSet:removeFromTable];	
	}
}

#pragma mark - BIT API Proxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	requestCount--;
	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
		
		if ([list count] > 0) {
            SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:[list objectAtIndex:0]] autorelease];
			NSLog(@"Received URLs for %@", bookIdentifier);
            
            // if this is a different version then update the ContentMetadataItem
            // this guarentees the OnDiskVersion will be set correctly
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:bookIdentifier 
                                                               inManagedObjectContext:self.managedObjectContext];

            if (book != nil) {
                NSString *resultVersion = [[list objectAtIndex:0] valueForKey:kSCHLibreAccessWebServiceVersion];
                if (resultVersion != nil &&
                    [book.ContentMetadataItem.Version isEqualToString:resultVersion] == NO) {
                    book.ContentMetadataItem.Version = resultVersion;
                }
            }
            
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

        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:bookIdentifier
                                                                                               forKey:kSCHBookIdentifierBookIdentifier]];	
	}
    
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}	
	
    [self shakeTable];
}

#pragma mark - Authentication Manager Notification methods

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
    NSNumber *offlineMode = [userInfo valueForKey:kSCHAuthenticationManagerOfflineMode];
    
    if (offlineMode != nil && [offlineMode boolValue] == NO) {
		[self shakeTable];	
	}
}

@end
