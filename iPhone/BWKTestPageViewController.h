//
//  XPSTestViewController.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWKXPSProvider.h"
#import "BWKScrubberView.h"

@interface BWKTestPageViewController : UIViewController <UIScrollViewDelegate, BWKScrubberViewDelegate> {
	IBOutlet UIView *pageView;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *pageLabel;
	IBOutlet UILabel *panSpeedLabel;
	IBOutlet UIBarButtonItem *previousButton;
	IBOutlet UIBarButtonItem *nextButton;
	
	IBOutlet UIToolbar *topToolbar;
	IBOutlet UIToolbar *bottomToolbar;
	
	IBOutlet BWKScrubberView *pageScrubber;
	IBOutlet UIView *scrubberInfoView;
	
	BWKXPSProvider *testRenderer;
	NSString *xpsPath;
	
	int currentPage;
	
	bool toolbarsVisible;
	NSTimer *initialFadeTimer;
}

@property (nonatomic, retain) NSString *xpsPath;

- (IBAction) previousPage: (id) sender;
- (IBAction) nextPage: (id) sender;	
- (IBAction) backAction: (id) sender;
//- (IBAction) sliderValueChanged: (id) sender;
//- (IBAction) sliderChangesStarted: (id) sender;
//- (IBAction) sliderChangesEnded: (id) sender;



- (void) loadImageForCurrentPage;
- (void) checkButtonStatus;
- (void) toggleToolbarVisibility;
- (void) cancelInitialTimer;
- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated;

@end
