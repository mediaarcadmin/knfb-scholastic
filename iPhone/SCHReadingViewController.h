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

@interface SCHReadingViewController : UIViewController <BITScrubberViewDelegate, SCHReadingViewDelegate> {
	
	IBOutlet UIToolbar          *scrubberToolbar;
    IBOutlet UIToolbar          *youngerTopToolbar;
    IBOutlet UIToolbar          *olderTopToolbar;
    IBOutlet UIToolbar          *olderBottomToolbar;

	IBOutlet BITScrubberView    *pageScrubber;

	IBOutlet UIView             *scrubberInfoView;
	IBOutlet UILabel            *pageLabel;
	IBOutlet UILabel            *panSpeedLabel;
    IBOutlet UIBarButtonItem    *youngerBookTitle;
    IBOutlet UIBarButtonItem    *olderBookTitle;
	
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) SCHReadingView *eucPageView;
@property (nonatomic) BOOL flowView;
@property (readwrite) BOOL youngerMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

- (IBAction)nextSmartZoom:(id)sender;
- (IBAction)prevSmartZoom:(id)sender;

@end
