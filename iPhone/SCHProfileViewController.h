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
#import "SCHProfileSetupDelegate.h"
#import "SCHAppController.h"
#import "DDPageControl.h"
#import "SCHHitTestExtendingView.h"

@class SCHSettingsViewController;
@class SCHProfileItem;
@class SCHBookShelfViewController;

@interface SCHProfileViewController : UIViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate> {}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *parentButton;
@property (nonatomic, retain) IBOutlet DDPageControl *pageControl;
@property (nonatomic, retain) IBOutlet SCHHitTestExtendingView *forwardingView;
@property (nonatomic, retain) IBOutlet UIImageView *updatesBubble;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) id<SCHProfileSetupDelegate> profileSetupDelegate;
@property (nonatomic, assign) id<SCHAppController> appController;

- (NSArray *)profileItems;
- (NSArray *)viewControllersForProfileItem:(SCHProfileItem *)profileItem showWelcome:(BOOL)welcome;

- (SCHBookShelfViewController *)newBookShelfViewController;
- (IBAction)settings:(id)sender;

@end
