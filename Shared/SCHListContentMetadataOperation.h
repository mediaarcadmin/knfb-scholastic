//
//  SCHListContentMetadataOperation.h
//  Scholastic
//
//  Created by John Eddie on 22/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSyncComponentOperation.h"

@class SCHContentMetadataItem;

@interface SCHListContentMetadataOperation : SCHSyncComponentOperation

@property (nonatomic, assign) BOOL useIndividualRequests;

- (void)syncContentMetadataItems:(NSArray *)contentMetadataList 
            managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (SCHContentMetadataItem *)addContentMetadataItem:(NSDictionary *)webContentMetadataItem
                              managedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)syncContentMetadataItem:(NSDictionary *)webContentMetadataItem
        withContentMetadataItem:(SCHContentMetadataItem *)localContentMetadataItem;

@end
