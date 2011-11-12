//
//  SCHDownloadDictionaryViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseModalViewController.h"
#import "SCHProfileSetupDelegate.h"

@interface SCHDownloadDictionaryViewController : SCHBaseModalViewController {}

@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *labels;
@property (nonatomic, retain) IBOutlet UILabel *downloadSizeLabel;
@property (nonatomic, retain) IBOutlet UIButton *downloadDictionaryButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (IBAction)downloadDictionary:(id)sender;

@end
