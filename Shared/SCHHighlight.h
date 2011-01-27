//
//  SCHHighlight.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"


@interface SCHHighlight :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Color;
@property (nonatomic, retain) NSNumber * EndPage;

@end



