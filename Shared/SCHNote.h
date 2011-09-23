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
@class SCHBookPoint;

// Constants
extern NSString * const kSCHNote;

@interface SCHNote :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSString * Color;
@property (nonatomic, retain) NSString * Value;
@property (nonatomic, retain) SCHLocationGraphics * Location;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

// backed by convenience methods
@property (nonatomic, retain) UIColor *NoteColor;
@property (nonatomic, retain) NSString *NoteText;
@property (nonatomic, assign) NSUInteger noteLayoutPage;

@end



