//
//  SCHAnnotationsContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

@class SCHAnnotationsList;
@class SCHPrivateAnnotations;

@interface SCHAnnotationsContentItem :  SCHContentItem  
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) SCHAnnotationsList * AnnotationsList;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



