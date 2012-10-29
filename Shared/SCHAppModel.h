//
//  SCHAppModel.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kSCHAppModelErrorDomain;
extern NSInteger const kSCHAppModelErrorBookDoesntExist;
extern NSInteger const kSCHAppModelErrorBookRequiresNetworkConnection;

@protocol SCHAppController;

@class SCHAuthenticationManager;
@class SCHSyncManager;
@class SCHAppStateManager;
@class SCHBookIdentifier;

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

// Temp State methods TODO: remove these and replace with sync-centric methods

- (void)waitForPassword;
- (void)waitForSettings;
- (void)waitForBookshelves;
- (void)waitForWebParentToolsToComplete;
- (void)waitForTourBookWithIdentifier:(SCHBookIdentifier *)identifier;

- (void)waitForSettingsWithSyncManager:(SCHSyncManager *)syncManager;
- (void)waitForBookshelvesWithSyncManager:(SCHSyncManager *)syncManager;
- (void)waitForWebParentToolsToCompleteWithSyncManager:(SCHSyncManager *)syncManager;

// Interrogate App State

- (BOOL)hasBooksToImport;
- (BOOL)hasExtraSampleBooks;

// Interrogate Book State
- (BOOL)canOpenBookWithIdentifier:(SCHBookIdentifier *)identifier error:(NSError **)error;
- (NSInteger)bookshelfStyleForBookWithIdentifier:(SCHBookIdentifier *)identifier;

// Exposed for testing purposes

- (BOOL)hasProfilesInManagedObjectContext:(NSManagedObjectContext *)moc;


@end
