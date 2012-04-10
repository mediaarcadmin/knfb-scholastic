//
//  SCHCOPPAManager.h
//  Scholastic
//
//  Created by John Eddie on 20/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxyDelegate.h"

@interface SCHCOPPAManager : NSObject <BITAPIProxyDelegate>

+ (SCHCOPPAManager *)sharedCOPPAManager;

- (void)checkCOPPAIfRequired;
- (void)resetCOPPA;

@end
