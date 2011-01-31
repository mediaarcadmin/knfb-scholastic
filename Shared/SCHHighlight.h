//
//  SCHHighlight.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"

@class SCHLocationText;
@class SCHPrivateAnnotations;

@interface SCHHighlight :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Color;
@property (nonatomic, retain) NSNumber * EndPage;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;
@property (nonatomic, retain) SCHLocationText * LocationText;

@end



