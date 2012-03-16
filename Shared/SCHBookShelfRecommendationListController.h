//
//  SCHBookShelfRecommendationListController.h
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppProfile.h"

@interface SCHBookShelfRecommendationListController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) SCHAppProfile *appProfile;
@property (nonatomic, copy) dispatch_block_t closeBlock;
@property (nonatomic, retain) IBOutlet UITableView *mainTableView;

@end
