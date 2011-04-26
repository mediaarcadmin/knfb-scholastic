//
//  SCHReadingOptionsView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHReadingViewController;
@class SCHProfileItem;

@interface SCHReadingOptionsView : UIViewController 
{
}

@property (nonatomic, retain) IBOutlet UIImageView *coverImageView;
@property (nonatomic, retain) IBOutlet UIView *bookCoverView;
@property (nonatomic, retain) IBOutlet UIView *optionsView;

@property (nonatomic, retain) NSTimer *initialFadeTimer;	

@property (nonatomic, retain) SCHReadingViewController *pageViewController;
@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) UIImage *thumbnailImage;
@property (nonatomic, retain) SCHProfileItem *profileItem;
@property (nonatomic, retain) IBOutlet UIButton *favouriteButton;
@property (nonatomic, retain) IBOutlet UIImageView *shadowView;

- (IBAction)showFlowView:(id)sender;
- (IBAction)showFixedView:(id)sender;
- (IBAction)tapBookCover:(id)sender;
- (IBAction)toggleFavorite:(id)sender;
- (void)cancelInitialTimer;

@end
