//
//  SCHAppState.h
//  Scholastic
//
//  Created by John S. Eddie on 09/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

static NSString * const kSCHAppState = @"SCHAppState";

static NSString * const kSCHAppStatefetchAppState = @"fetchAppState";

@interface SCHAppState : NSManagedObject 
{
}

@property (nonatomic, retain) NSDate * LastAnnotationSync;

@end
