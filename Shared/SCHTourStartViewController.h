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
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *greyButtons;
@property (retain, nonatomic) IBOutlet UIScrollView *iPhoneScrollView;
@property (retain, nonatomic) IBOutlet UIView *titleView;

@property (retain, nonatomic) IBOutlet UIImageView *iPhoneTopImageView;


- (IBAction)startReading:(UIButton *)sender;

@end
