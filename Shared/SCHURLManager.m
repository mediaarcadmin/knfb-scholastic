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

static SCHURLManager *sharedURLManager = nil;

@interface SCHURLManager ()

+ (SCHURLManager *)sharedURLManagerOnMainThread;
- (void)requestURLForISBNOnMainThread:(NSString *)ISBN;
- (void)clearOnMainThread;
- (void)shakeTable;

@property (retain, nonatomic) NSMutableSet *table;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (retain, nonatomic) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, assign) NSInteger requestCount;

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
    if (sharedURLManager == nil) {
        // we block until the selector completes to make sure we always have the object before use
        [SCHURLManager performSelectorOnMainThread:@selector(sharedURLManagerOnMainThread) withObject:nil waitUntilDone:YES];
    }
	
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
													 name:kSCHAuthenticationManagerSuccess object:nil];					
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) 
													 name:kSCHAuthenticationManagerFailure object:nil];							
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

- (void)requestURLForISBN:(NSString *)ISBN
{
    [self performSelectorOnMainThread:@selector(requestURLForISBNOnMainThread:) withObject:ISBN waitUntilDone:NO];
}
	
- (void)clear
{
    [self performSelectorOnMainThread:@selector(clearOnMainThread) withObject:nil waitUntilDone:NO];    
}

#pragma - Private methods

+ (SCHURLManager *)sharedURLManagerOnMainThread
{
    if (sharedURLManager == nil) {
        sharedURLManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedURLManager);
}

- (void)requestURLForISBNOnMainThread:(NSString *)ISBN
{	
	if (ISBN != nil) {
		NSEntityDescription *entityDescription = [NSEntityDescription 
												  entityForName:kSCHUserContentItem 
												  inManagedObjectContext:self.managedObjectContext];
		NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
										fetchRequestFromTemplateWithName:kSCHUserContentItemFetchWithContentIdentifier 
										substitutionVariables:[NSDictionary 
															   dictionaryWithObject:ISBN 
															   forKey:kSCHUserContentItemCONTENT_IDENTIFIER]];
		
		NSArray *book = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
		
		if ([book count] > 0) {
			[table addObject:[book objectAtIndex:0]];
			[self shakeTable];
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
																object:self];
        }
	}
}

- (void)clearOnMainThread
{
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
			if ([self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:contentMetaDataItem] 
													includeURLs:YES] == YES) {
				NSLog(@"Requesting URLs for %@", [contentMetaDataItem 
												valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);
				
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
			NSLog(@"Received URLs for %@", [[list objectAtIndex:0] 
												   valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess 
																object:self userInfo:[list objectAtIndex:0]];				
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
																object:self];
		}		
	}
	
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	requestCount--;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:self];	
	
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}		
}

#pragma mark - Authentication Manager Notification methods

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	if ([[userInfo valueForKey:kSCHAuthenticationManagerOfflineMode] boolValue] == NO) {
		NSLog(@"Authenticated!");
		
		[self shakeTable];	
	} else if ([table count] > 0) {
		[self clear];
		[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:self];			
	}
}

@end
