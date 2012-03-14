//
//  SCHRecommendationItem.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHRecommendationISBN;

// Constants
extern NSString * const kSCHRecommendationItem;

@interface SCHRecommendationItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSNumber * regularPrice;
@property (nonatomic, retain) NSNumber * salePrice;
@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) SCHRecommendationISBN *isbn;
@property (nonatomic, retain) NSManagedObject *profile;

@end
