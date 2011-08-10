//
//  SCHBookshelfSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHBookshelfSyncComponentWillDeleteNotification;
extern NSString * const SCHBookshelfSyncComponentDeletedBookIdentifiers;
extern NSString * const SCHBookshelfSyncComponentBookReceivedNotification;
extern NSString * const SCHBookshelfSyncComponentDidCompleteNotification;
extern NSString * const SCHBookshelfSyncComponentDidFailNotification;

@interface SCHBookshelfSyncComponent : SCHSyncComponent
{
}

@property (nonatomic, assign) BOOL useIndividualRequests;

- (void)addContentMetadataItem:(NSDictionary *)webContentMetadataItem;

@end
