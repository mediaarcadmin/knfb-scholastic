//
//  SCHProfilePasswordViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 16/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHProfilePasswordViewControllerDelegate.h"

@class SCHProfileItem;

@interface SCHProfilePasswordViewController : UIViewController 
{

}

@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) SCHProfileItem *profileItem;
@property (assign, nonatomic) id<SCHProfilePasswordViewControllerDelegate> delegate;

- (IBAction)OK:(id)sender;
- (IBAction)cancel:(id)sender;

@end
