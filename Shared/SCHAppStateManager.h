//
//  SCHAppStateManager.h
//  Scholastic
//
//  Created by John S. Eddie on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHAppState.h"

@class NSManagedObjectContext;

@interface SCHAppStateManager : NSObject 
{    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHAppStateManager *)sharedAppStateManager;

- (SCHAppState *)appState;
- (void)createAppStateIfNeeded;
- (BOOL)canDownloadBooks;
- (BOOL)canSync;
- (BOOL)canAuthenticate;
- (BOOL)isStandardStore;
- (BOOL)isSampleStore;
- (BOOL)isLocalDebugStore;

@end
