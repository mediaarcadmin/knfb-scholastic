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
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHUserContentItem+Extensions.h"

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];					
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];							
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
	
	// TODO: Test for duplication
	if (ISBN != nil) {
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kSCHUserContentItem inManagedObjectContext:self.managedObjectContext];
		NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel fetchRequestFromTemplateWithName:@"fetchWithContentIdentifier" substitutionVariables:[NSDictionary dictionaryWithObject:ISBN forKey:@"CONTENT_IDENTIFIER"]];
		
		NSArray *book = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
		
		ret = [book count] > 0;
		if (ret == YES) {
			[table addObject:[book objectAtIndex:0]];
			[self shakeTable];
		}
	}
	
	return(ret);
}
									 
- (void)clear
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
			if ([self.libreAccessWebService listContentMetadata:[NSArray arrayWithObject:contentMetaDataItem] includeURLs:YES] == YES) {
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

#pragma mark -
#pragma mark BIT API Proxy Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	requestCount--;
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}
	
	if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		NSArray *list = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];
		
		if ([list count] > 0) {
			NSLog(@"%@ URL information received", [[list objectAtIndex:0] valueForKey:kSCHLibreAccessWebServiceContentIdentifier]);
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerSuccess object:[list objectAtIndex:0]];				
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:nil];
		}		
	}	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	requestCount--;
	if (requestCount < 1) {
		if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
			self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
		}
	}	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHURLManagerFailure object:nil];	
}

#pragma mark -
#pragma mark Authentication Manager Notification methods

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	if ([[userInfo valueForKey:kSCHAuthenticationManagerOfflineMode] boolValue] == NO) {
		NSLog(@"Authenticated!");
		
		[self shakeTable];	
	}
}

@end
