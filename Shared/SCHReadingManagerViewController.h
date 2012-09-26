//
//  SCHReadingManagerViewController.h
//  Scholastic
//
//  Created by Matt Farrugia on 14/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@interface SCHReadingManagerViewController : UIViewController

@property (nonatomic, copy) NSString *pToken;
@property (nonatomic, assign) id<SCHAppController> appController;

@end