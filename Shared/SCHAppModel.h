//
//  SCHAppModel.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHAppController;

@class SCHAuthenticationManager;
@class SCHSyncManager;
@class SCHAppStateManager;

@interface SCHAppModel : NSObject

- (id)initWithAppController:(id<SCHAppController>)appController;

// Shared Instance Actions

- (void)restoreAppState;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)setupSamples;
- (void)setupTour;

// Actions

- (void)restoreAppStateWithAppStateManager:(SCHAppStateManager *)appStateManager
                     authenticationManager:(SCHAuthenticationManager *)authenticationManager
                               syncManager:(SCHSyncManager *)syncManager;
- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
              syncManager:(SCHSyncManager *)syncManager
    authenticationManager:(SCHAuthenticationManager *)authenticationManager;

// Temp State methods TODO: remove

- (void)waitForPassword;
- (void)waitForBookshelves;
- (void)waitForWebParentToolsToComplete;

- (void)waitForBookshelvesWithSyncManager:(SCHSyncManager *)syncManager;
- (void)waitForWebParentToolsToCompleteWithSyncManager:(SCHSyncManager *)syncManager;

// Interogate App State

- (BOOL)hasBooksToImport;
- (BOOL)hasExtraSampleBooks;

// Exposed for testing purposes

- (BOOL)hasProfilesInManagedObjectContext:(NSManagedObjectContext *)moc;


@end
