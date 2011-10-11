//
//  SCHContentSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHContentSyncComponentWillDeleteNotification;
extern NSString * const SCHContentSyncComponentDeletedBookIdentifiers;
extern NSString * const SCHContentSyncComponentDidAddBookToProfileNotification;
extern NSString * const SCHContentSyncComponentAddedBookIdentifier;
extern NSString * const SCHContentSyncComponentAddedProfileIdentifier;
extern NSString * const SCHContentSyncComponentDidCompleteNotification;
extern NSString * const SCHContentSyncComponentDidFailNotification;

@interface SCHContentSyncComponent : SCHSyncComponent
{
}

- (NSArray *)localUserContentItems;
- (void)addUserContentItem:(NSDictionary *)webUserContentItem;

@end
