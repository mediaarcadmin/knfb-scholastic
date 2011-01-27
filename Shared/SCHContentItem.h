//
//  SCHContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHContentItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSNumber * ContentIdentifierType;
@property (nonatomic, retain) NSString * ContentIdentifier;

@end



