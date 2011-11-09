//
//  SCHComponentDelegate.h
//  Scholastic
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHComponent;

@protocol SCHComponentDelegate

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result;
- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error;
- (void)authenticationDidSucceed;

@end
