//
//  BWKReadingOptionsView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWKTestPageViewController.h"
#import "SCHContentMetadataItem.h"

@interface BWKReadingOptionsView : UIViewController {

	IBOutlet UIImageView *coverImageView;
	IBOutlet UIView *bookCoverView;
	IBOutlet UILabel *authorLabel;
	
	NSTimer *initialFadeTimer;
	
}

@property (readwrite, retain) BWKTestPageViewController *pageViewController;
@property (readwrite, retain) SCHContentMetadataItem *metadataItem;

- (IBAction) showBookView: (id) sender;
- (IBAction) tapBookCover: (id) sender;
- (void) cancelInitialTimer;

@end
