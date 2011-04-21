//
//  SCHReadingViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010-2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BITScrubberView.h"
#import "SCHReadingView.h"
#import "SCHCustomToolbar.h"

@class SCHXPSProvider;

@interface SCHReadingViewController : UIViewController <BITScrubberViewDelegate, SCHReadingViewDelegate> {
	
	IBOutlet SCHCustomToolbar   *scrubberToolbar;
    IBOutlet SCHCustomToolbar   *olderBottomToolbar;

	IBOutlet BITScrubberView    *pageScrubber;

	IBOutlet UIView             *scrubberInfoView;
	IBOutlet UILabel            *pageLabel;
//	IBOutlet UILabel            *panSpeedLabel;
    IBOutlet UILabel            *youngerBookTitleLabel;
    IBOutlet UIView             *youngerBookTitleView;
	
    IBOutlet UILabel            *olderBookTitleLabel;
    IBOutlet UIView             *olderBookTitleView;
    IBOutlet UIView             *optionsView;
    
    IBOutlet UISegmentedControl *flowFixedSegmentedControl;
    IBOutlet UISegmentedControl *fontSegmentedControl;
    IBOutlet UISegmentedControl *paperTypeSegmentedControl;
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) SCHReadingView *eucPageView;
@property (nonatomic) BOOL flowView;
@property (readwrite) BOOL youngerMode;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

- (IBAction)nextSmartZoom:(id)sender;
- (IBAction)prevSmartZoom:(id)sender;

@end
