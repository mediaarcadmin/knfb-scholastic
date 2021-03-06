//
//  SCHBookShelfRecommendationListController.h
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppProfile.h"
#import "SCHRecommendationListView.h"
#import "SCHCustomToolbar.h"

@protocol SCHBookShelfRecommendationListControllerDelegate;

@interface SCHBookShelfRecommendationListController : UIViewController <UITableViewDelegate, UITableViewDataSource, SCHRecommendationListViewDelegate>


@property (nonatomic, assign) id <SCHBookShelfRecommendationListControllerDelegate> delegate;
@property (nonatomic, retain) SCHAppProfile *appProfile;
@property (nonatomic, copy) dispatch_block_t closeBlock;
@property (nonatomic, assign) BOOL shouldShowWishList; // default to yes

// IB
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet SCHCustomToolbar *topToolbar;
@property (retain, nonatomic) IBOutlet SCHCustomToolbar *bottomToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *bottomSegment;

@end

@protocol SCHBookShelfRecommendationListControllerDelegate <NSObject>

- (void)switchToWishListFromRecommendationListController:(SCHBookShelfRecommendationListController *)recommendationController;

@end