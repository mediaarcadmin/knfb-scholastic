//
//  SCHNote.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"

@class SCHLocationGraphics;
@class SCHPrivateAnnotations;

static NSString * const kSCHNote = @"SCHNote";

@interface SCHNote :  SCHAnnotation  
{
}

@property (nonatomic, retain) UIColor * Color;
@property (nonatomic, retain) NSString * Value;
@property (nonatomic, retain) SCHLocationGraphics * LocationGraphics;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



