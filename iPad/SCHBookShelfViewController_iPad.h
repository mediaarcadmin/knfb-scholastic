//
//  SCHBookShelfViewController_iPad.h
//  Scholastic
//
//  Created by Gordon Christie on 16/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"

#import "SCHBookShelfSortPopoverTableView.h"
#import "SCHComponentDelegate.h"
#import "SCHBookShelfRecommendationListController.h"
#import "SCHBookShelfWishListController.h"
#import "SCHBookShelfMenuTableViewController.h"

@class SCHProfileViewController_iPad;

@interface SCHBookShelfViewController_iPad : SCHBookShelfViewController <UIPopoverControllerDelegate, SCHBookShelfSortPopoverTableViewDelegate, 
                                                                         SCHComponentDelegate, SCHBookShelfRecommendationListControllerDelegate, SCHBookShelfWishListControllerDelegate> 
{    
}

@end
