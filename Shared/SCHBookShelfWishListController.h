//
//  SCHBookShelfWishListController.h
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppProfile.h"
#import "SCHRecommendationListView.h"


@protocol SCHBookShelfWishListControllerDelegate;

@interface SCHBookShelfWishListController : UIViewController <UITableViewDelegate, UITableViewDataSource, SCHRecommendationListViewDelegate>

@property (nonatomic, assign) id <SCHBookShelfWishListControllerDelegate> delegate;
@property (nonatomic, retain) SCHAppProfile *appProfile;
@property (nonatomic, copy) dispatch_block_t closeBlock;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;

@end

@protocol SCHBookShelfWishListControllerDelegate <NSObject>

- (void)switchToRecommendationsFromWishListController:(SCHBookShelfWishListController *)wishListController;

@end
