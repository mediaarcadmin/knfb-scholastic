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

// FIXME: can we standardise on synthesized ivars for IBOutlets?
@interface SCHReadingViewController : UIViewController <BITScrubberViewDelegate, SCHReadingViewDelegate> {

	IBOutlet BITScrubberView    *pageScrubber;
    IBOutlet UIImageView        *scrubberThumbImage;

	IBOutlet UIView             *scrubberInfoView;
	IBOutlet UILabel            *pageLabel;
//	IBOutlet UILabel            *panSpeedLabel;	
    IBOutlet UIView             *optionsView;
    
    IBOutlet UISegmentedControl *flowFixedSegmentedControl;
    IBOutlet UISegmentedControl *fontSegmentedControl;
    IBOutlet UISegmentedControl *paperTypeSegmentedControl;
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) SCHReadingView *eucPageView;
@property (nonatomic) BOOL flowView;
@property (readwrite) BOOL youngerMode;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *leftBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIView *youngerRightBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *audioButton;
@property (nonatomic, retain) IBOutlet UIButton *zoomButton;

@property (nonatomic, retain) IBOutlet SCHCustomToolbar   *scrubberToolbar;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar   *olderBottomToolbar;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet UIImageView *bottomShadow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

- (IBAction)nextSmartZoom:(id)sender;
- (IBAction)prevSmartZoom:(id)sender;
- (IBAction)popViewController:(id)sender;
- (IBAction)magnifyAction:(id)sender;
- (IBAction)audioPlayAction:(id)sender;

@end
