// 
//  SCHAnnotationsItem.m
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotationsItem.h"

#import "SCHAnnotationsContentItem.h"

// Constants
NSString * const kSCHAnnotationsItem = @"SCHAnnotationsItem";

NSString * const kSCHAnnotationsItemfetchAnnotationItemForProfile = @"fetchAnnotationItemForProfile";
NSString * const kSCHAnnotationsItemPROFILE_ID = @"PROFILE_ID";

@implementation SCHAnnotationsItem 

@dynamic ProfileID;
@dynamic AnnotationsContentItem;

@end
