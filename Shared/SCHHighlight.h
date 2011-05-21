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
@class SCHBookRange;

static NSString * const kSCHHighlight = @"SCHHighlight";

@interface SCHHighlight :  SCHAnnotation  
{
}

@property (nonatomic, retain) UIColor * Color;
@property (nonatomic, retain) NSNumber * EndPage;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;
@property (nonatomic, retain) SCHLocationText * LocationText;

- (NSUInteger)startLayoutPage;
- (NSUInteger)startWordOffset;
- (NSUInteger)endLayoutPage;
- (NSUInteger)endWordOffset;

@end



