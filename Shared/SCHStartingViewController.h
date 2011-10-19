//
//  SCHStartingViewController.h
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHStartingViewCell.h"
#import "SCHSettingsDelegate.h"

@class SCHLoginPasswordViewController;
@class SCHSetupBookshelvesViewController;
@class SCHDownloadDictionaryViewController;

@interface SCHStartingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SCHStartingViewCellDelegate, SCHSettingsDelegate> {}

@property (nonatomic, retain) IBOutlet UITableView *starterTableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *samplesHeaderView;
@property (nonatomic, retain) IBOutlet UIView *signInHeaderView;
@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;

@end
