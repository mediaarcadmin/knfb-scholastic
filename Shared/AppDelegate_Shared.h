//
//  AppDelegate_Shared.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHLoginErrorDomain;
extern NSInteger const kSCHLoginReachabilityError;
extern NSString * const kSCHSamplesErrorDomain;
extern NSInteger const kSCHSamplesUnspecifiedError;

typedef enum {
	kSCHStoreTypeStandardStore,
    kSCHStoreTypeSampleStore,
} SCHStoreType;

@class SCHCoreDataHelper;

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate> 
{    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) SCHCoreDataHelper *coreDataHelper;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationSupportDocumentsDirectory;

- (void)clearUserDefaults;
- (void)setStoreType:(SCHStoreType)storeType;
- (void)resetDictionaryStore;
- (void)recoverFromUnintializedDRM;

@end

