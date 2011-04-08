//
//  XPSTestViewController.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BITXPSProvider.h"
#import "BITScrubberView.h"
#import "SCHReadingView.h"

#define TESTPAGEVIEW_PAGETAPWIDTH 75

@interface BITTestPageViewController : UIViewController <UIScrollViewDelegate, BITScrubberViewDelegate> {
    IBOutlet UIView *pageView;
	SCHReadingView *eucPageView;
	IBOutlet UILabel *pageLabel;
	IBOutlet UILabel *panSpeedLabel;
	IBOutlet UIBarButtonItem *previousButton;
	IBOutlet UIBarButtonItem *nextButton;
	
	IBOutlet UIToolbar *topToolbar;
    IBOutlet UIToolbar *bottomToolbar;
	IBOutlet UIToolbar *scrubberToolbar;
	
	IBOutlet BITScrubberView *pageScrubber;
	IBOutlet UIView *scrubberInfoView;
	
	BITXPSProvider *testRenderer;
	
	int currentPage;
	
	bool toolbarsVisible;
	NSTimer *initialFadeTimer;
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic) BOOL flowView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

- (IBAction) previousPage: (id) sender;
- (IBAction) nextPage: (id) sender;	
- (IBAction) backAction: (id) sender;
- (void) goToFirstPage;

- (void) updatePageViewWithCurrentPage;
- (void) checkButtonStatus;
- (void) toggleToolbarVisibility;
- (void) cancelInitialTimer;
- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated;

@end
