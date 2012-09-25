//
//  SCHTourStartViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 17/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@interface SCHTourStartViewController : UIViewController

@property (nonatomic, assign) id<SCHAppController> appController;

- (IBAction)startReading:(UIButton *)sender;

@end
