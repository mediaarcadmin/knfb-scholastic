//
//  SCHSettingsViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCHDrmRegistrationSessionDelegate.h"

@class SCHCustomToolbar;

@protocol SCHSettingsViewControllerDelegate <NSObject>
- (void)dismissSettingsForm;
@end

@interface SCHSettingsViewController : UIViewController <SCHDrmRegistrationSessionDelegate, UIAlertViewDelegate>  
{}

@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHDrmRegistrationSession* drmRegistrationSession;
@property (nonatomic, assign) id<SCHSettingsViewControllerDelegate> settingsDelegate;

- (IBAction)dismissModalSettingsController:(id)sender;

@end
