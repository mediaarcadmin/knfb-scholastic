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
@class SCHSampleBooksImporter;

@interface SCHAppModel : NSObject

- (id)initWithAppController:(id<SCHAppController>)appController;

// Shared Instance Actions

- (void)restoreAppState;
- (void)setupPreview;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

// Actions

- (void)restoreAppStateWithAppStateManager:(SCHAppStateManager *)appStateManager
                     authenticationManager:(SCHAuthenticationManager *)authenticationManager
                               syncManager:(SCHSyncManager *)syncManager;
- (void)setupPreviewWithImporter:(SCHSampleBooksImporter *)importer;
- (void)loginWithUsername:(NSString *)username 
                 password:(NSString *)password 
              syncManager:(SCHSyncManager *)syncManager
    authenticationManager:(SCHAuthenticationManager *)authenticationManager;

// Temp State methods TODO: remove

- (void)waitForPassword;
- (void)waitForBookshelves;
- (void)waitForWebParentToolsToComplete;

@end
