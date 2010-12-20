//
//  XPSTestViewController.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XPSTestRenderer.h"


@interface XPSTestViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIView *pageView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *pageLabel;
	
	XPSTestRenderer *testRenderer;
	
	int currentPage;
}

- (IBAction) previousPage: (id) sender;
- (IBAction) nextPage: (id) sender;	
- (void) loadImageForCurrentPage;

@end
