//
//  BITReadingOptionsView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHReadingViewController.h"

@interface BITReadingOptionsView : UIViewController {

	IBOutlet UIImageView *coverImageView;
	IBOutlet UIView *bookCoverView;
	IBOutlet UIView *optionsView;
//	IBOutlet UILabel *titleLabel;
//	IBOutlet UILabel *authorLabel;
	
	NSTimer *initialFadeTimer;
	
}

@property (readwrite, retain) SCHReadingViewController *pageViewController;
@property (readwrite, retain) NSString *isbn;
@property (readwrite, retain) UIImage *thumbnailImage;

- (IBAction) showFlowView: (id) sender;
- (IBAction) showFixedView: (id) sender;
- (IBAction) tapBookCover: (id) sender;
- (void) cancelInitialTimer;

@end
