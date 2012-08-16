// 
//  SCHAnnotation.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotation.h"


@implementation SCHAnnotation 

@dynamic ID;
@dynamic Version;

+ (BOOL)isValidAnnotationID:(NSNumber *)annotationID
{
    return [annotationID integerValue] > 0;
}

@end
