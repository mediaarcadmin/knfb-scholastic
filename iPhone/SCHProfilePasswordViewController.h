//
//  SCHProfilePasswordViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 16/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SCHProfilePasswordViewControllerDelegate.h"
#import "SCHCustomToolbar.h"

@class SCHProfileItem;

@interface SCHProfilePasswordViewController : UIViewController 
{

    SCHCustomToolbar *topBar;
}

@property (retain, nonatomic) IBOutlet UILabel *newPasswordMessage;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) IBOutlet UITextField *confirmPassword;
@property (retain, nonatomic) SCHProfileItem *profileItem;
@property (assign, nonatomic) BOOL setPasswordMode;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) id<SCHProfilePasswordViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;

- (IBAction)OK:(id)sender;
- (IBAction)cancel:(id)sender;

@end
