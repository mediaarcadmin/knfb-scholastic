//
//  SCHDownloadDictionaryViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseSetupViewController.h"

@interface SCHDownloadDictionaryViewController : SCHBaseSetupViewController {}

@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *labels;
@property (nonatomic, retain) IBOutlet UIButton *downloadDictionaryButton;

- (IBAction)downloadDictionary:(id)sender;

@end
