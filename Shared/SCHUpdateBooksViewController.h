//
//  SCHUpdateBooksViewController.h
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHBookUpdates;

@interface SCHUpdateBooksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {}

@property (nonatomic, retain) IBOutlet UITableView *booksTable;
@property (nonatomic, retain) IBOutlet UIButton *updateBooksButton;
@property (nonatomic, retain) IBOutlet UILabel *estimatedDownloadTimeLabel;
@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (retain, nonatomic) IBOutlet UILabel *noteUpdateNoticeLabel;

- (IBAction)updateBooks:(id)sender;

@end
