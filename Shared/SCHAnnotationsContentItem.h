//
//  SCHAnnotationsContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

@class SCHAnnotationsItem;
@class SCHPrivateAnnotations;

@interface SCHAnnotationsContentItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) SCHAnnotationsItem * AnnotationsItem;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotation;

@end



