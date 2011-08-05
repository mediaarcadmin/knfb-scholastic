//
//  AppDelegate_Shared.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SCHCoreDataHelper;

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate> 
{    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) SCHCoreDataHelper *coreDataHelper;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationSupportDocumentsDirectory;

// YES if we have user authentication credentials (regardless of build type)
- (BOOL)isAuthenticated;

@end

