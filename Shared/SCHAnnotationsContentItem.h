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

static NSString * const kSCHAnnotationsContentItem = @"SCHAnnotationsContentItem";

@interface SCHAnnotationsContentItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) SCHAnnotationsItem * AnnotationsList;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



