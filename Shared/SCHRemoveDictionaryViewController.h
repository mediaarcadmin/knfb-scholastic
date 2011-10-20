//
//  SCHRemoveDictionaryViewController.h
//  Scholastic
//
//  Created by Neil Gall on 22/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseModalViewController.h"

@interface SCHRemoveDictionaryViewController : SCHBaseModalViewController {}

@property (nonatomic, retain) IBOutlet UIButton *removeDictionaryButton;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *labels;

- (IBAction)removeDictionary:(id)sender;

@end
