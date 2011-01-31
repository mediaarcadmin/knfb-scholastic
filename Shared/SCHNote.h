//
//  SCHNote.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"

@class SCHLocationGraphics;

@interface SCHNote :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Color;
@property (nonatomic, retain) NSString * Value;
@property (nonatomic, retain) SCHLocationGraphics * LocationGraphics;
@property (nonatomic, retain) NSManagedObject * PrivateAnnotations;

@end



