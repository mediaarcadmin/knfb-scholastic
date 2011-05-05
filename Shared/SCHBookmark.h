//
//  SCHBookmark.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"

@class SCHPrivateAnnotations;
@class SCHLocationBookmark;

static NSString * const kSCHBookmark = @"SCHBookmark";

@interface SCHBookmark :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSNumber * Disabled;
@property (nonatomic, retain) NSString * Text;
@property (nonatomic, retain) SCHLocationBookmark * LocationBookmark;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



