//
//  SCHBookmark.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHAnnotation.h"

@class SCHPrivateAnnotations;

@interface SCHBookmark :  SCHAnnotation  
{
}

@property (nonatomic, retain) NSNumber * Disabled;
@property (nonatomic, retain) NSString * Text;
@property (nonatomic, retain) NSNumber * Page;
@property (nonatomic, retain) SCHPrivateAnnotations * PrivateAnnotations;

@end



