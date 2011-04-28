//
//  SCHProfileViewController.h
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SCHProfilePasswordViewControllerDelegate.h"

@class SCHProfilePasswordViewController;
@class SCHSettingsViewController;
@class SCHLoginPasswordViewController;

@interface SCHProfileViewController : UIViewController <NSFetchedResultsControllerDelegate, SCHProfilePasswordViewControllerDelegate> {
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet SCHProfilePasswordViewController *profilePasswordViewController;
@property (nonatomic, retain) IBOutlet SCHSettingsViewController *settingsController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
