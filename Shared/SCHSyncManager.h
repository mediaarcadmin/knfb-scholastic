//
//  SCHSyncManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHProfileSyncComponent;
@class SCHContentSyncComponent;
@class SCHBookshelfSyncComponent;
@class SCHAnnotationSyncComponent;
@class SCHReadingStatsSyncComponent;
@class SCHSettingsSyncComponent;

@interface SCHSyncManager : NSObject 
{	
	SCHBackgroundSync *backgroundSync;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHSyncManager *)sharedSyncManager;

- (void)startBackgroundSync;
- (void)stopBackgroundSync;

- (void)firstSync;
- (void)openDocument;
- (void)closeDocument;
- (void)exitParentalTools:(BOOL)syncNow;

@end
