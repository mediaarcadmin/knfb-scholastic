//
//  SCHDownloadDictionaryViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@interface SCHDownloadDictionaryViewController : UIViewController {}

@property (nonatomic, retain) IBOutlet UIButton *actionButton;
@property (nonatomic, retain) IBOutlet UIButton *downloadLaterButton;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *shadowView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, assign) id<SCHAppController> appController;
@property (nonatomic, copy) dispatch_block_t completionBlock;

- (IBAction)downloadDictionary:(id)sender;
- (IBAction)removeDictionary:(id)sender;
- (IBAction)close:(id)sender;

- (void)startDictionaryDownload;

@end
