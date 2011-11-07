// 
//  SCHLastPage.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHLastPage.h"
#import "NSNumber+ObjectTypes.h"

// Constants
NSString * const kSCHLastPage = @"SCHLastPage";

@implementation SCHLastPage 

@dynamic LastPageLocation;
@dynamic Component;
@dynamic Percentage;
@dynamic PrivateAnnotations;

- (void)setInitialValues
{
    self.LastPageLocation = [NSNumber numberWithInteger:0];
    self.Component = @"";
    self.Percentage = [NSNumber numberWithFloat:0.0];
 
    self.LastModified = [NSDate distantPast];
    self.State = [NSNumber numberWithStatus:kSCHStatusUnmodified];    
}

@end
