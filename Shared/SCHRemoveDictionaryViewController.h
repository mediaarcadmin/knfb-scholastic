//
//  SCHRemoveDictionaryViewController.h
//  Scholastic
//
//  Created by Neil Gall on 22/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseSetupViewController.h"

@interface SCHRemoveDictionaryViewController : SCHBaseSetupViewController {}

@property (nonatomic, retain) IBOutlet UIButton *removeDictionaryButton;

- (IBAction)removeDictionary:(id)sender;

@end
