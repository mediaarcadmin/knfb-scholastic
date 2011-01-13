//
//  SCHContentMetadataItem.h
//  Scholastic
//
//  Created by John S. Eddie on 12/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHContentMetadataItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * ProductType;
@property (nonatomic, retain) NSString * ContentIdentifier;
@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) NSNumber * ContentIdentifierType;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSString * Title;

@end



