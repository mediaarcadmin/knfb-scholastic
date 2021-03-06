//
//  SCHContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "SCHISBNItem.h"

@class SCHBookIdentifier;

@interface SCHContentItem :  NSManagedObject <SCHISBNItem>
{
}

@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSNumber * ContentIdentifierType;
@property (nonatomic, retain) NSString * ContentIdentifier;

- (SCHBookIdentifier *)bookIdentifier;

@end



