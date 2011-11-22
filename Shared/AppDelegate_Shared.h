//
//  AppDelegate_Shared.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCHStartingViewController.h"

typedef enum {
	kSCHStoreTypeStandardStore,
    kSCHStoreTypeSampleStore,
} SCHStoreType;

@class SCHCoreDataHelper;

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate> 
{    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SCHStartingViewController *startingViewController;
@property (nonatomic, readonly) SCHCoreDataHelper *coreDataHelper;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationSupportDocumentsDirectory;

- (void)clearUserDefaults;
- (void)setStoreType:(SCHStoreType)storeType;
- (void)resetDictionaryStore;

@end

