//
//  SCHReadingNotesViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

@interface SCHReadingNotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *topShadow;
}

@property (nonatomic, retain) NSString *isbn;

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *notesCell;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;

- (IBAction)cancelButtonAction:(id)sender;

@end
