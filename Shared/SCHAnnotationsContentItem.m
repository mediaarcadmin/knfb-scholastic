// 
//  SCHAnnotationsContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotationsContentItem.h"

#import "SCHAnnotationsItem.h"
#import "SCHPrivateAnnotations.h"

// Constants
NSString * const kSCHAnnotationsContentItem = @"SCHAnnotationsContentItem";

NSString * const kSCHAnnotationsContentItemfetchAnnotationsContentItemsForBook = @"fetchAnnotationsContentItemsForBook";
NSString * const kSCHAnnotationsContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHAnnotationsContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@implementation SCHAnnotationsContentItem 

@dynamic Format;
@dynamic AverageRating;
@dynamic AnnotationsItem;
@dynamic PrivateAnnotations;

@end
