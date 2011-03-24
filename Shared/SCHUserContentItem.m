// 
//  SCHUserContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHUserContentItem.h"

#import "SCHContentProfileItem.h"
#import "SCHOrderItem.h"

@implementation SCHUserContentItem 

@dynamic Format;
@dynamic Version;
@dynamic ContentIdentifier;
@dynamic ContentIdentifierType;
@dynamic DefaultAssignment;
@dynamic DRMQualifier;
@dynamic OrderList;
@dynamic ProfileList;

- (NSSet *)AssignedProfileList
{
	return(self.ProfileList);
}

@end
