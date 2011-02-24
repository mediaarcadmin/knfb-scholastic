//
//  BITNetworkActivityManager.h
//  Scholastic
//
//  Created by John S. Eddie on 23/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BITNetworkActivityManager : NSObject 
{

}

+ (BITNetworkActivityManager *)sharedNetworkActivityManager;

- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;

@end
