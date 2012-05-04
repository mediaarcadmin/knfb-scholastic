//
//  SCHSetupBookshelvesViewController.h
//  Scholastic
//
//  Created by Neil Gall on 19/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseModalViewController.h"

@interface SCHSetupBookshelvesViewController : SCHBaseModalViewController {}

@property (nonatomic, retain) IBOutlet UIButton *setupBookshelvesButton;

- (IBAction)setupBookshelves:(id)sender;
- (IBAction)deregister:(id)sender;

@end
