//
//  SCHProfileViewController_iPad.h
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileViewController_Shared.h"

@class SCHBookShelfViewController_iPad;
@class SCHLoginPasswordViewController;
@class SCHCustomNavigationBar;

@interface SCHProfileViewController_iPad : SCHProfileViewController_Shared <UITableViewDelegate> {
    
    UINavigationController *settingsNavigationController;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) SCHBookShelfViewController_iPad *bookshelfViewController;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;

@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginPasswordController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *profilePasswordController;
@property (nonatomic, retain) IBOutlet UINavigationController *settingsNavController;

@end
