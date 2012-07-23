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

- (id)initWithAppController:(id<SCHAppController>)appController; // uses shared instances

- (id)initWithAppController:(id<SCHAppController>)appController
            appStateManager:(SCHAppStateManager *)appStateManager
      authenticationManager:(SCHAuthenticationManager *)authenticationManager
                syncManager:(SCHSyncManager *)syncManager;

// Actions

- (void)setupPreview;
- (void)setupPreviewWithImporter:(SCHSampleBooksImporter *)importer;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;


// Temp State methods TODO: remove

- (void)waitingForPassword;
- (void)waitingForBookshelves;
- (void)waitingForWebParentToolsToComplete;

@end
