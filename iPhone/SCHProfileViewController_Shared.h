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
#import "SCHSettingsDelegate.h"
#import "SCHProfileSetupDelegate.h"

@class SCHSettingsViewController;
@class SCHProfileItem;
@class SCHBookShelfViewController;

@interface SCHProfileViewController_Shared : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate, SCHSettingsDelegate> {}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;
@property (nonatomic, retain) IBOutlet SCHSettingsViewController *settingsViewController;
@property (nonatomic, retain) IBOutlet UIImageView *updatesBubble;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) id<SCHProfileSetupDelegate> profileSetupDelegate;

- (NSArray *)profileItems;
- (NSArray *)viewControllersForProfileItem:(SCHProfileItem *)profileItem;

// for use by subclass
- (void)releaseViewObjects;
- (void)pushSettingsController;

- (SCHBookShelfViewController *)newBookShelfViewController;

@end
