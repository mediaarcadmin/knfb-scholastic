//
//  SCHSettingsViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SCHAppController.h"

@class SCHCustomToolbar;
@class SCHCheckbox;
@class SCHUpdateBooksViewController;

typedef enum {
    kSCHSettingsPanelReadingManager     = 1 << 1,
    kSCHSettingsPanelAdditionalSettings = 1 << 2,
    kSCHSettingsPanelDictionaryDownload = 1 << 3,
    kSCHSettingsPanelDictionaryDelete   = 1 << 4,
    kSCHSettingsPanelDeregisterDevice   = 1 << 5,
    kSCHSettingsPanelSupport            = 1 << 6,
    kSCHSettingsPanelEbookUpdates       = 1 << 7,
    kSCHSettingsPanelAll                = 0
} SCHSettingsPanel;

@interface SCHSettingsViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {}

@property (nonatomic, assign) id <SCHAppController> appController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *transformableView;
@property (nonatomic, retain) IBOutlet UIView *shadowView;

@property (nonatomic, retain) IBOutlet UIView *contentView; // iPad only
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, assign) NSUInteger settingsDisplayMask; // defaults to kSCHSettingsPanelAll
@property (nonatomic, assign) BOOL backButtonHidden; // defaults to NO

- (void)displaySettingsPanel:(SCHSettingsPanel)panel;
- (IBAction)close:(id)sender;

@end
