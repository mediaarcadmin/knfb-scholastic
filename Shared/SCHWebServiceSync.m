//
//  SCHWebServiceSync.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHWebServiceSync.h"

#import "SCHScholasticWebService.h"
#import "SCHLibreAccessWebService.h"

@interface SCHWebServiceSync ()

- (void)updateProfiles:(NSArray *)profileList;
- (void)updateBooks:(NSArray *)bookList;

@end

@implementation SCHWebServiceSync

@synthesize scholasticWebService;
@synthesize libreAccessWebService;
@synthesize aToken;
@synthesize managedObjectContext;

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.aToken = nil;
		
		self.scholasticWebService = [[SCHScholasticWebService alloc] init];
		self.scholasticWebService.delegate = self;
		[self.scholasticWebService release];
		
		self.libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		self. libreAccessWebService.delegate = self;
		[self.libreAccessWebService release];
	}
	return(self);
}

- (void)dealloc
{
	self.scholasticWebService = nil;
	self.libreAccessWebService = nil;
	self.aToken = nil;
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (void)update
{
	[self.scholasticWebService authenticateUserName:@"eparent15" withPassword:@"pass"];	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
//	NSLog(@"%@", result);
	
	if([method compare:kSCHScholasticWebServiceProcessRemote] == NSOrderedSame) {	
		[self.libreAccessWebService tokenExchange:[result objectForKey:kSCHScholasticWebServicePToken] forUser:@"eparent15"];
	} else if([method compare:kSCHLibreAccessWebServiceTokenExchange] == NSOrderedSame) {	
		if (self.aToken == nil) {
			self.aToken = [result objectForKey:kSCHLibreAccessWebServiceAuthToken];
		}
		[self.libreAccessWebService getUserProfiles:self.aToken];
		[self.libreAccessWebService listUserContent:self.aToken];		
	} else if([method compare:kSCHLibreAccessWebServiceGetUserProfiles] == NSOrderedSame) {
		[self updateProfiles:[result objectForKey:kSCHLibreAccessWebServiceProfileList]];
	} else if([method compare:kSCHLibreAccessWebServiceListUserContent] == NSOrderedSame) {
		[self.libreAccessWebService listContentMetadata:self.aToken includeURLs:NO forBooks:[result objectForKey:kSCHLibreAccessWebServiceUserContentList]];				
	} else if([method compare:kSCHLibreAccessWebServiceListContentMetadata] == NSOrderedSame) {
		[self updateBooks:[result objectForKey:kSCHLibreAccessWebServiceContentMetadataList]];
	}
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	NSLog(@"%@", error);	
}

- (void)updateProfiles:(NSArray *)profileList
{	
	for (id profile in profileList) {
		NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ProfileItem" inManagedObjectContext:self.managedObjectContext];
		
		[newManagedObject setValue:[profile objectForKey:kSCHLibreAccessWebServiceLastModified] forKey:kSCHLibreAccessWebServiceLastModified];
		[newManagedObject setValue:[NSNumber numberWithInteger:0] forKey:@"state"];		
		[newManagedObject setValue:[profile objectForKey:kSCHLibreAccessWebServiceID] forKey:kSCHLibreAccessWebServiceID];
		[newManagedObject setValue:[profile objectForKey:kSCHLibreAccessWebServiceScreenname] forKey:kSCHLibreAccessWebServiceScreenname];
		[newManagedObject setValue:[profile objectForKey:kSCHLibreAccessWebServiceProfilePasswordRequired] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];		
	}
	
	// Save the context.
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}

- (void)updateBooks:(NSArray *)bookList
{	
	for (id book in bookList) {
		NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"ContentMetadataItem" inManagedObjectContext:self.managedObjectContext];

		[newManagedObject setValue:[book objectForKey:kSCHLibreAccessWebServiceTitle] forKey:kSCHLibreAccessWebServiceTitle];
		[newManagedObject setValue:[book objectForKey:kSCHLibreAccessWebServiceAuthor] forKey:kSCHLibreAccessWebServiceAuthor];
	}
	
	// Save the context.
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
}


@end
