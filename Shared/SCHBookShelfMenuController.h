//
//  SCHBookShelfMenuController.h
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileItem.h"
#import "SCHThemePickerViewController.h"
#import "SCHBookShelfSortTableView.h"
#import "SCHBookShelfTypeMenuTableController.h"

@protocol SCHBookShelfMenuControllerDelegate;

@interface SCHBookShelfMenuController : UITableViewController <SCHBookShelfSortTableViewDelegate, SCHBookShelfTypeMenuTableControllerDelegate, SCHThemePickerViewControllerDelegate>

@property (nonatomic, assign) id <SCHBookShelfMenuControllerDelegate> delegate;
@property (nonatomic, assign) BOOL userIsAuthenticated;

@end

@protocol SCHBookShelfMenuControllerDelegate <NSObject>

// switching between shelf types
- (void)bookShelfMenuSwitchedToGridView:(SCHBookShelfMenuController *)controller;
- (void)bookShelfMenuSwitchedToListView:(SCHBookShelfMenuController *)controller;

// bookshelf sorting
- (SCHBookSortType)sortTypeForBookShelfMenu:(SCHBookShelfMenuController *)controller;
- (void)bookShelfMenu:(SCHBookShelfMenuController *)controller changedSortType:(SCHBookSortType)newSortType;

// cancel out of the menu
- (void)bookShelfMenuCancelled:(SCHBookShelfMenuController *)controller;

// recommendations/wish list need the app profile
- (SCHAppProfile *)appProfileForBookShelfMenu;

@optional

// recommendations/wish list - iPad only
- (void)bookShelfMenuSelectedRecommendations:(SCHBookShelfMenuController *)controller;


@end