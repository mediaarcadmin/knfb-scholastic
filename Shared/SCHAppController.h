//
//  SCHAppController.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHBookIdentifier;
@class SCHProfileItem;

@protocol SCHAppController <NSObject>

@required

// Presentation Methods
- (void)presentLogin;
- (void)presentTour;
- (void)presentSamples;
- (void)presentProfiles;
- (void)presentProfilesAfterLogin;
- (void)presentProfilesSetup;
- (void)presentBookshelfForProfile:(SCHProfileItem *)profileItem;
- (void)presentReadingManager;
- (void)presentSettings;
- (void)presentSettingsWithExpandedNavigation;
- (void)presentDictionaryDownload;
- (void)presentDictionaryDelete;
- (void)presentDeregisterDevice;
- (void)presentSupport;
- (void)presentEbookUpdates;
- (void)presentDeviceDeregistered;

// Book Presentation Methods
- (void)presentTourBookWithIdentifier:(SCHBookIdentifier *)identifier;
- (void)presentSampleBookWithIdentifier:(SCHBookIdentifier *)identifier;
- (void)presentAccountBookWithIdentifier:(SCHBookIdentifier *)identifier;

// Exit Methods
- (void)exitBookshelf;
- (void)exitReadingManager;
- (void)exitBook;

// TODO: refactor these
- (void)waitForWebParentToolsToComplete;

// Failure Methods
- (void)failedSamplesWithError:(NSError *)error;
- (void)failedLoginWithError:(NSError *)error;
- (void)failedSyncWithError:(NSError *)error;

@end
