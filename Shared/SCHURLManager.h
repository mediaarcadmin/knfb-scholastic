//
//  SCHURLManager.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

@class SCHContentMetadataItem;

static NSString * const kSCHURLManagerSuccess = @"AuthenticationManagerSuccess";
static NSString * const kSCHURLManagerFailure = @"AuthenticationManagerFailure";

@interface SCHURLManager : NSObject <BITAPIProxyDelegate>
{	

}

+ (SCHURLManager *)sharedURLManager;

- (void)requestURLFor:(SCHContentMetadataItem *)contentMetaDataItem;
- (void)clear;

@end
