//
//  SCHBookShelfSortPopoverTableView.h
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBookShelfViewController.h"
#import "SCHProfileItem.h"

@protocol SCHBookShelfSortPopoverTableViewDelegate;

@interface SCHBookShelfSortPopoverTableView : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
}
@property (nonatomic, assign) id<SCHBookShelfSortPopoverTableViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *itemsTableView;
@property (nonatomic) SCHBookSortType sortType;

@end

@protocol SCHBookShelfSortPopoverTableViewDelegate <NSObject>

@optional
- (void)sortPopoverPickedSortType: (SCHBookSortType) newType;

@end