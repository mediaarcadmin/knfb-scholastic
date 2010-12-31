//
//  XPSTestViewController.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWKXPSProvider.h"


@interface BWKTestPageViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIView *pageView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *pageLabel;
	IBOutlet UIBarButtonItem *previousButton;
	IBOutlet UIBarButtonItem *nextButton;
	
	
	BWKXPSProvider *testRenderer;
	NSString *xpsPath;
	
	int currentPage;
}

@property (nonatomic, retain) NSString *xpsPath;

- (IBAction) previousPage: (id) sender;
- (IBAction) nextPage: (id) sender;	
- (void) loadImageForCurrentPage;
- (void) checkButtonStatus;

@end
