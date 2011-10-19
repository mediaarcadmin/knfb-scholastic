//
//  SCHSettingsViewControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LambdaAlert.h"

@protocol SCHSetupDelegate <NSObject>

- (void)dismissSettingsFormWithAlert:(LambdaAlert *)alert;

@end
