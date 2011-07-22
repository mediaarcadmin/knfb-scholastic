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
#import "SCHSettingsViewControllerDelegate.h"

@class SCHLoginPasswordViewController;
@class SCHSetupBookshelvesViewController;
@class SCHDownloadDictionaryViewController;
@class SCHSettingsViewController;

@interface SCHProfileViewController_Shared : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate, SCHSettingsViewControllerDelegate> {}

@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginPasswordController;
@property (nonatomic, retain) IBOutlet SCHSetupBookshelvesViewController *setupBookshelvesViewController;
@property (nonatomic, retain) IBOutlet SCHDownloadDictionaryViewController *downloadDictionaryViewController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *profilePasswordController;
@property (nonatomic, retain) IBOutlet SCHSettingsViewController *settingsViewController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// for use by subclass
- (void)releaseViewObjects;
- (void)pushSettingsController;


@end
