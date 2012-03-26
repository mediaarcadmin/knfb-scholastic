//
//  SCHBookShelfMenuTableViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileItem.h"
#import "SCHBookShelfSortTableView.h"
#import "SCHThemePickerViewController.h"

@protocol SCHBookShelfMenuControllerDelegate;

@interface SCHBookShelfMenuController : UITableViewController <SCHBookShelfSortTableViewDelegate>

@property (nonatomic, assign) id <SCHBookShelfMenuControllerDelegate> delegate;
@property (nonatomic, assign) BOOL userIsAuthenticated;

@end

@protocol SCHBookShelfMenuControllerDelegate <NSObject>

// switching between shelf types
- (NSString *)shelfSwitchTextForBookShelfMenu:(SCHBookShelfMenuController *)controller;
- (void)bookShelfMenuToggledSwitch:(SCHBookShelfMenuController *)controller;

// bookshelf sorting
- (SCHBookSortType)sortTypeForBookShelfMenu:(SCHBookShelfMenuController *)controller;
- (void)bookShelfMenu:(SCHBookShelfMenuController *)controller changedSortType:(SCHBookSortType)newSortType;

// recommendations/wish list
- (void)bookShelfMenuSelectedRecommendations:(SCHBookShelfMenuController *)controller;

@end