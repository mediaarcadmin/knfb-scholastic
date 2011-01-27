//
//  SCHBookmark.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"


@interface SCHBookmark :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Text;
@property (nonatomic, retain) NSNumber * Disabled;

@end



