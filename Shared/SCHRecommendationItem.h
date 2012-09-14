//
//  SCHRecommendationItem.h
//  Scholastic
//
//  Created by John Eddie on 13/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHAppRecommendationISBN;
@class SCHAppRecommendationProfile;
@class SCHAppRecommendationItem;

// Constants
extern NSString * const kSCHRecommendationItem;

@interface SCHRecommendationItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * image_link;
@property (nonatomic, retain) NSNumber * regular_price;
@property (nonatomic, retain) NSNumber * sale_price;
@property (nonatomic, retain) NSString * product_code;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) SCHAppRecommendationItem *appRecommendationItem;
@property (nonatomic, retain) SCHAppRecommendationISBN *appRecommendationISBN;
@property (nonatomic, retain) SCHAppRecommendationProfile *appRecommendationProfile;

- (NSString *)isbn;
- (void)assignAppRecommendationItem;

+ (BOOL)isValidItemID:(NSString *)itemID;

@end
