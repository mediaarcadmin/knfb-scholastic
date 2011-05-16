//
//  SCHProfileViewController_iPad.h
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileViewController_Shared.h"


@interface SCHProfileViewController_iPad : SCHProfileViewController_Shared <UITableViewDelegate> {
    
    UITableView *tableView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
