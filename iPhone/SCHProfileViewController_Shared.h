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

@class SCHLoginPasswordViewController;
@class SCHSetupBookshelvesViewController;
@class SCHDownloadDictionaryViewController;

@interface SCHProfileViewController_Shared : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate> {
}

@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;
@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginPasswordController;
@property (nonatomic, retain) IBOutlet SCHSetupBookshelvesViewController *setupBookshelvesViewController;
@property (nonatomic, retain) IBOutlet SCHDownloadDictionaryViewController *downloadDictionaryViewController;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// for use by subclass
- (void)releaseViewObjects;
- (void)advanceToNextLoginStep;
- (void)endLoginSequence;
- (void)dismissKeyboard;

@end
