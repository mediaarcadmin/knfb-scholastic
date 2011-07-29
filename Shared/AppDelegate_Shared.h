//
//  AppDelegate_Shared.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate_Shared : NSObject <UIApplicationDelegate> 
{    
    UIWindow *window;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly ) NSManagedObjectContext *managedObjectContext;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationSupportDocumentsDirectory;
- (void)saveContext;
- (void)checkForModeSwitch;

// YES if we have user authentication credentials (regardless of build type)
- (BOOL)isAuthenticated;

// remove everything from the CoreData database
- (void)clearDatabase;

@end

