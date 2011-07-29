//
//  SCHSettingsViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SCHBaseSetupViewController.h"

@class SCHCustomToolbar;
@class SCHCheckbox;
@class SCHUpdateBooksViewController;

@interface SCHSettingsViewController : SCHBaseSetupViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>  
{}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView; // iPhone only
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
