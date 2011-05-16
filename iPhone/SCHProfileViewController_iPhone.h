//
//  SCHProfileViewController_iPhone.h
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileViewController_Shared.h"

@class SCHSettingsViewController;
@class SCHLoginPasswordViewController;



@interface SCHProfileViewController_iPhone : SCHProfileViewController_Shared <UITableViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet SCHSettingsViewController *settingsController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *profilePasswordController;


@end
