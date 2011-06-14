//
//  SCHBookShelfTopTenPopoverTableView.h
//  Scholastic
//
//  Created by Gordon Christie on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHBookShelfTopTenPopoverTableView : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{    
}

@property (nonatomic, retain) IBOutlet UITableView *topTenTableView;
@property (nonatomic, copy) NSArray *books;

@end