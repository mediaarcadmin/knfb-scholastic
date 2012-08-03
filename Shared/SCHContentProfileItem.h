//
//  SCHContentProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHUserContentItem;
@class SCHAppContentProfileItem;
@class SCHBookIdentifier;

// Constants
extern NSString * const kSCHContentProfileItem;

@interface SCHContentProfileItem :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSNumber * LastPageLocation;
@property (nonatomic, retain) SCHUserContentItem * UserContentItem;
@property (nonatomic, retain) SCHAppContentProfileItem * AppContentProfileItem;
@property (nonatomic, retain) NSNumber * Rating;

- (void)deleteAnnotationsForBook:(SCHBookIdentifier *)bookIdentifier;
- (void)deleteStatisticsForBook:(SCHBookIdentifier *)bookIdentifier;

@end



