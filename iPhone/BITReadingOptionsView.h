//
//  BITReadingOptionsView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHReadingViewController.h"
#import "SCHProfileItem.h"

@interface BITReadingOptionsView : UIViewController {

	IBOutlet UIImageView *coverImageView;
	IBOutlet UIView *bookCoverView;
	IBOutlet UIView *optionsView;
//	IBOutlet UILabel *titleLabel;
//	IBOutlet UILabel *authorLabel;
	
	NSTimer *initialFadeTimer;
	
}

@property (nonatomic, retain) SCHReadingViewController *pageViewController;
@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) SCHProfileItem *profileItem;
@property (nonatomic, retain) IBOutlet UIButton *favouriteButton;
@property (nonatomic, retain) IBOutlet UIImageView *shadowView;

- (IBAction) showFlowView: (id) sender;
- (IBAction) showFixedView: (id) sender;
- (IBAction) tapBookCover: (id) sender;
- (IBAction)toggleFavorite:(id)sender;
- (void) cancelInitialTimer;

@end
