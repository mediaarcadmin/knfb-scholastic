//
//  SCHContentMetadataItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentItem.h"


@interface SCHContentMetadataItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * Enhanced;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * FileName;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSSet* eReaderCategories;

@end


@interface SCHContentMetadataItem (CoreDataGeneratedAccessors)
- (void)addEReaderCategoriesObject:(NSManagedObject *)value;
- (void)removeEReaderCategoriesObject:(NSManagedObject *)value;
- (void)addEReaderCategories:(NSSet *)value;
- (void)removeEReaderCategories:(NSSet *)value;

@end

