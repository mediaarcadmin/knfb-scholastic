//
//  SCHBookshelfSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

@class SCHContentMetadataItem;

// Constants
extern NSString * const SCHBookshelfSyncComponentWillDeleteNotification;
extern NSString * const SCHBookshelfSyncComponentBookIdentifiers;
extern NSString * const SCHBookshelfSyncComponentBookReceivedNotification;
extern NSString * const SCHBookshelfSyncComponentDidCompleteNotification;
extern NSString * const SCHBookshelfSyncComponentDidFailNotification;

@interface SCHBookshelfSyncComponent : SCHSyncComponent
{
}

@property (atomic, assign) BOOL useIndividualRequests;

- (SCHContentMetadataItem *)addContentMetadataItemFromMainThread:(NSDictionary *)webContentMetadataItem;
- (void)syncContentMetadataItemsFromMainThread:(NSArray *)contentMetadataList;
- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem
        withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem;

@end
