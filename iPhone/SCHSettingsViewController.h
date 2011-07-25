//
//  SCHSettingsViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseSetupViewController.h"
#import "SCHSetupDelegate.h"

@class SCHCustomToolbar;
@class SCHCheckbox;
@class SCHUpdateBooksViewController;

@interface SCHSettingsViewController : SCHBaseSetupViewController <UIAlertViewDelegate, SCHSetupDelegate>  
{}

@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIButton *manageBooksButton;
@property (nonatomic, retain) IBOutlet UIButton *deregisterDeviceButton;
@property (nonatomic, retain) IBOutlet UIButton *updateBooksButton;
@property (nonatomic, retain) IBOutlet UIButton *downloadDictionaryButton;
@property (nonatomic, retain) IBOutlet SCHCheckbox *spaceSaverSwitch;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)dismissModalSettingsController:(id)sender;
- (IBAction)manageBooks:(id)sender;
- (IBAction)deregisterDevice:(id)sender;
- (IBAction)updateBooks:(id)sender;
- (IBAction)downloadDictionary:(id)sender;
- (IBAction)showAboutView:(id)sender;
- (IBAction)showPrivacyPolicy:(id)sender;
- (IBAction)contactCustomerSupport:(id)sender;

@end
