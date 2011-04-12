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
    IBOutlet UIView    *pageView;
	
	IBOutlet UIToolbar *topToolbar;
    IBOutlet UIToolbar *bottomToolbar;
	IBOutlet UIToolbar *scrubberToolbar;
	
	IBOutlet BITScrubberView *pageScrubber;

	IBOutlet UIView    *scrubberInfoView;
	IBOutlet UILabel   *pageLabel;
	IBOutlet UILabel   *panSpeedLabel;
	
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic) BOOL flowView;
@property (nonatomic, retain) SCHReadingView *eucPageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn;

@end
