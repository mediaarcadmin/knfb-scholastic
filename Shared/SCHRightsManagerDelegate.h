//
//  SCHRightsManagerDelegate.h
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHRightsManager;

@protocol SCHRightsManagerDelegate

- (void)rightsManager:(SCHRightsManager *)rightsManager didComplete:(NSString *)deviceKey;
- (void)rightsManager:(SCHRightsManager *)rightsManager didFailWithError:(NSError *)error;

@end
