//
//  SCHNote.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"


@interface SCHNote :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Color;
@property (nonatomic, retain) NSString * Value;

@end



