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

static NSString * const kSCHURLManagerSuccess = @"URLManagerSuccess";
static NSString * const kSCHURLManagerFailure = @"URLManagerFailure";

@interface SCHURLManager : NSObject <BITAPIProxyDelegate>
{	

}

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (SCHURLManager *)sharedURLManager;

- (BOOL)requestURLForISBN:(NSString *)ISBN;
- (void)clear;

@end
