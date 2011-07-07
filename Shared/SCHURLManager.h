//
//  SCHURLManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;

static NSString * const kSCHURLManagerSuccess = @"URLManagerSuccess";
static NSString * const kSCHURLManagerFailure = @"URLManagerFailure";

@interface SCHURLManager : NSObject <BITAPIProxyDelegate>
{	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHURLManager *)sharedURLManager;

- (void)requestURLForBook:(SCHBookIdentifier *)bookIdentifier;
- (void)clear;

@end
