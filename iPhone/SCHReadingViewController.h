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

@class SCHXPSProvider;
@class SCHCustomToolbar;

@interface SCHReadingViewController : UIViewController <BITScrubberViewDelegate, SCHReadingViewDelegate> {

}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic) BOOL flowView;
@property (readwrite) BOOL youngerMode;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *leftBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIView *youngerRightBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *audioButton;
@property (nonatomic, retain) IBOutlet UIButton *zoomButton;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *scrubberToolbar;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *olderBottomToolbar;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet UIImageView *bottomShadow;

@property (nonatomic, retain) IBOutlet BITScrubberView *pageScrubber;
@property (nonatomic, retain) IBOutlet UIImageView *scrubberThumbImage;
@property (nonatomic, retain) IBOutlet UIView *scrubberInfoView;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;
@property (nonatomic, retain) IBOutlet UILabel *panSpeedLabel;	

@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *flowFixedSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fontSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *paperTypeSegmentedControl;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

@end
