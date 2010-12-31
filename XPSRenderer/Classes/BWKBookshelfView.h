//
//  BWKBookshelfView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 31/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BWKBookshelfView : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	IBOutlet UITableView *shelfTableView;
	
	NSArray *xpsFiles;
	
}

@property (nonatomic, retain) NSArray *xpsFiles;

@end
