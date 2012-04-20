//
//  SCHProfileItemSortObject.h
//  Scholastic
//
//  Created by John Eddie on 20/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHContentMetadataItem;

@interface SCHProfileItemSortObject : NSObject

@property (nonatomic, retain) SCHContentMetadataItem *item;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isNewBook;

@end
