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

@property (atomic, assign) BOOL useIndividualRequests;
@property (atomic, assign) NSInteger requestCount;
@property (nonatomic, retain) NSMutableArray *didReceiveFailedResponseBooks;

- (NSArray *)bookIdentifiersFromRequestInfo:(NSArray *)contentMetadataItems;
- (SCHContentMetadataItem *)addContentMetadataItemFromMainThread:(NSDictionary *)webContentMetadataItem;
- (void)syncContentMetadataItemsFromMainThread:(NSArray *)contentMetadataList;

@end
