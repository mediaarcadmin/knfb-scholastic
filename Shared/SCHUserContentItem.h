//
//  SCHUserContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"


@interface SCHUserContentItem :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSNumber * DefaultAssignment;
@property (nonatomic, retain) NSNumber * ContentIdentifierType;

@end



