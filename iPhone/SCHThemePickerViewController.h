//
//  SCHThemePickerViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomNavigationBar;

@interface SCHThemePickerViewController : UIViewController 
{

}

@property (nonatomic, retain) IBOutlet UITableView *aTableView;
@property (nonatomic, retain) IBOutlet SCHCustomNavigationBar *customNavigationBar;

@end
