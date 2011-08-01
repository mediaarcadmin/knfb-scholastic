//
//  SCHProfileViewController.h
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCHProfileViewCell.h"
#import "SCHSetupDelegate.h"

@class SCHSettingsViewController;
@class SCHProfileItem;
@class SCHBookShelfViewController;

@interface SCHProfileViewController_Shared : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate, SCHSetupDelegate> {}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;
@property (nonatomic, retain) IBOutlet SCHSettingsViewController *settingsViewController;
@property (nonatomic, retain) IBOutlet UIImageView *updatesBubble;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// for use by subclass
- (void)releaseViewObjects;
- (void)pushSettingsController;

- (SCHBookShelfViewController *)newBookShelfViewController;


@end
