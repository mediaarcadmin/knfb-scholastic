//
//  SCHThemePickerViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHThemePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIImageView *shadowView;

@end
