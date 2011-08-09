//
//  SCHAppStateManager.m
//  Scholastic
//
//  Created by John S. Eddie on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAppStateManager.h"

#import <CoreData/CoreData.h>
#import "SCHCoreDataHelper.h"

@implementation SCHAppStateManager

@synthesize managedObjectContext;

#pragma mark - Singleton Instance methods

+ (SCHAppStateManager *)sharedAppStateManager
{
    static dispatch_once_t pred;
    static SCHAppStateManager *sharedAppStateManager = nil;
    
    dispatch_once(&pred, ^{
        sharedAppStateManager = [[super allocWithZone:NULL] init];		
    });
	
    return(sharedAppStateManager);
}

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
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
    
    [super dealloc];
}

#pragma mark - methods

- (SCHAppState *)appState
{
    SCHAppState *ret = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription 
                                              entityForName:kSCHAppState
                                              inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                    fetchRequestTemplateForName:kSCHAppStatefetchAppState];
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSArray *state = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];	
    
    if ([state count] > 0) {
        ret = [state objectAtIndex:0];
    } else {
        [self createAppStateIfNeeded];
    }
    
    return(ret);    
}

- (void)createAppStateIfNeeded
{
    NSError *error = nil;
    
    [NSEntityDescription insertNewObjectForEntityForName:kSCHAppState 
                                  inManagedObjectContext:self.managedObjectContext];
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (BOOL)canDownloadBooks
{
    BOOL ret = NO;
    SCHAppState *appState = [self appState];
    
    if (appState != nil) {
        ret = [appState.ShouldDownloadBooks boolValue];
    }
    
    return(ret);
}

- (BOOL)canSync
{
    BOOL ret = NO;
    SCHAppState *appState = [self appState];
    
    if (appState != nil) {
        ret = [appState.ShouldSync boolValue];
    }
    
    return(ret);
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

@end
