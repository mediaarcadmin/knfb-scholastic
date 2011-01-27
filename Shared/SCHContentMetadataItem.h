//
//  SCHContentMetadataItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentItem.h"


@interface SCHContentMetadataItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * ProductType;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * FileName;
@property (nonatomic, retain) NSString * Description;

@end



