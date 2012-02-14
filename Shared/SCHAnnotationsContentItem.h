//
//  SCHAnnotationsContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

@class SCHAnnotationsItem;
@class SCHPrivateAnnotations;

// Constants
extern NSString * const kSCHAnnotationsContentItem;

extern NSString * const kSCHAnnotationsContentItemfetchAnnotationsContentItemsForBook;
extern NSString * const kSCHAnnotationsContentItemCONTENT_IDENTIFIER;
extern NSString * const kSCHAnnotationsContentItemDRM_QUALIFIER;

@interface SCHAnnotationsContentItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSString * AverageRating;
@property (nonatomic, retain) SCHAnnotationsItem * AnnotationsItem;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



