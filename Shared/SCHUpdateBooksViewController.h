//
//  SCHUpdateBooksViewController.h
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseModalViewController.h"

@class SCHBookUpdates;

@interface SCHUpdateBooksViewController : SCHBaseModalViewController <UITableViewDataSource, UITableViewDelegate> {}

@property (nonatomic, retain) IBOutlet UITableView *booksTable;
@property (nonatomic, retain) IBOutlet UIButton *updateBooksButton;
@property (nonatomic, retain) IBOutlet UILabel *estimatedDownloadTimeLabel;
@property (nonatomic, retain) SCHBookUpdates *bookUpdates;

- (IBAction)updateBooks:(id)sender;

@end
