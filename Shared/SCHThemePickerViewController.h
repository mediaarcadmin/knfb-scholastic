//
//  SCHThemePickerViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHThemePickerViewControllerDelegate;

@interface SCHThemePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
}
@property (nonatomic, assign) id <SCHThemePickerViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end


@protocol SCHThemePickerViewControllerDelegate <NSObject>

- (void)themePickerControllerSelectedClose:(SCHThemePickerViewController *)controller;

@end