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

- (void)shakeTable;

@property (retain, nonatomic) NSMutableSet *table;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (retain, nonatomic) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, assign) NSInteger requestCount;

@end

@implementation SCHURLManager

@synthesize managedObjectContext;
@synthesize table;
@synthesize backgroundTaskIdentifier;
@synthesize libreAccessWebService;
@synthesize requestCount;

#pragma mark -
#pragma mark Singleton Instance methods

+ (SCHURLManager *)sharedURLManager
{
    if (sharedURLManager == nil) {
        sharedURLManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedURLManager);
}

#pragma mark -
#pragma mark methods

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
	
	self.table = nil;
	self.libreAccessWebService = nil;

	[super dealloc];
}

- (BOOL)requestURLForISBN:(NSString *)ISBN
{
	BOOL ret = NO;
	
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
		
		ret = [book count] > 0;
		if (ret == YES) {
			@synchronized(table) {
			[table addObject:[book objectAtIndex:0]];
			[self shakeTable];
			}
		}
	}
	
	return(ret);
}
									 
- (void)clear
{
	@synchronized(table) {
	[table removeAllObjects];
	}
}

- (void)shakeTable
{	
	@synchronized(table) {
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
}

// FIXME: added a method to make the notifications fire on the main thread

- (void) postSuccess: (NSArray *) objectArray
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess 
														object:[objectArray objectAtIndex:0] userInfo:[objectArray objectAtIndex:1]];				
}

- (void) postFailure: (id) object
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
														object:object];				
}
		  
#pragma mark -
#pragma mark BIT API Proxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	requestCount--;
	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
		
		if ([list count] > 0) {
			NSLog(@"Received URLs for %@", [[list objectAtIndex:0] 
												   valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);
//			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess 
//																object:self userInfo:[list objectAtIndex:0]];	
			NSArray *argsArray = [NSArray arrayWithObjects:self, [list objectAtIndex:0], nil];
			
			[self performSelectorOnMainThread:@selector(postSuccess:) withObject:argsArray waitUntilDone:YES];
			
		} else {
//			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure 
//																object:self];
			[self performSelectorOnMainThread:@selector(postFailure:) withObject:self waitUntilDone:YES];
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
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:self];	
	[self performSelectorOnMainThread:@selector(postFailure:) withObject:self waitUntilDone:YES];
	
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}		
}

#pragma mark -
#pragma mark Authentication Manager Notification methods

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	if ([[userInfo valueForKey:kSCHAuthenticationManagerOfflineMode] boolValue] == NO) {
//		NSLog(@"Authenticated!");
		
		[self shakeTable];	
	} else if ([table count] > 0) {
		[self clear];
//		[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:self];			
		[self performSelectorOnMainThread:@selector(postFailure:) withObject:self waitUntilDone:YES];
	}
}

@end
