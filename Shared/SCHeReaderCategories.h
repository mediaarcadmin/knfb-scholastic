//
//  SCHeReaderCategories.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHContentMetadataItem;

@interface SCHeReaderCategories :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Category;
@property (nonatomic, retain) SCHContentMetadataItem * ContentMetadataItem;

@end



