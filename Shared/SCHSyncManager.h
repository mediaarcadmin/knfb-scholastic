//
//  SCHSyncManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHComponentDelegate.h"

@interface SCHSyncManager : NSObject <SCHComponentDelegate>
{	

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHSyncManager *)sharedSyncManager;

- (void)start;
- (void)stop;

- (void)firstSync;
- (void)openDocument:(NSString *)ISBN forProfile:(NSNumber *)profileID;
- (void)openDocumentForProfile:(NSString *)ISBN forProfile:(NSNumber *)profileID;
- (void)exitParentalTools:(BOOL)syncNow;

@end
