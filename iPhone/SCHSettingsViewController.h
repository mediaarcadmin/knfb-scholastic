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

@class SCHLoginPasswordViewController;

@interface SCHSettingsViewController : UIViewController <SCHDrmRegistrationSessionDelegate>  
{
}

@property (nonatomic, retain) IBOutlet SCHLoginPasswordViewController *loginController;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHDrmRegistrationSession* drmRegistrationSession;

- (IBAction)dismissModalSettingsController:(id)sender;

@end
