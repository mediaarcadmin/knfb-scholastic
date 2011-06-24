//
//  SCHReadingViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010-2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHReadingView.h"
#import "SCHAudioBookPlayerDelegate.h"
#import "SCHReadingNotesListController.h"
#import "SCHReadingInteractionsListController.h"
#import "SCHReadingNoteView.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import <AVFoundation/AVAudioPlayer.h>

typedef enum 
{
	SCHReadingViewPaperTypeWhite = 0,
	SCHReadingViewPaperTypeBlack,
	SCHReadingViewPaperTypeSepia
} SCHReadingViewPaperType;

typedef enum 
{
	SCHReadingViewLayoutTypeFlow = 0,
	SCHReadingViewLayoutTypeFixed,
} SCHReadingViewLayoutType;

@class SCHCustomToolbar;
@class SCHProfileItem;

@interface SCHReadingViewController : UIViewController <SCHReadingViewDelegate, SCHReadingNotesListControllerDelegate, 
SCHReadingNoteViewDelegate, SCHReadingInteractionsListControllerDelegate, SCHAudioBookPlayerDelegate, UIPopoverControllerDelegate,
SCHStoryInteractionControllerDelegate, AVAudioPlayerDelegate> 
{}


@property (nonatomic, assign) BOOL youngerMode;

// interface builder
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *leftBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIView *youngerRightBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIView *olderRightBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *audioButtons;
@property (nonatomic, retain) IBOutlet UIButton *notesButton;
@property (nonatomic, retain) IBOutlet UIButton *storyInteractionsListButton;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *scrubberToolbar;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *olderBottomToolbar;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet UIImageView *bottomShadow;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UIImageView *scrubberThumbImage;
@property (nonatomic, retain) IBOutlet UIView *scrubberInfoView;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;
@property (nonatomic, retain) IBOutlet UILabel *panSpeedLabel;	

@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UIViewController *popoverOptionsViewController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fontSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *paperTypeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *flowFixedSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *flowFixedPopoverSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *paperTypePopoverSegmentedControl;

@property (nonatomic, retain) IBOutlet UIButton *storyInteractionButton;
@property (nonatomic, retain) IBOutlet UIView *storyInteractionButtonView;
@property (nonatomic, retain) IBOutlet UIView *youngerToolbarToggleView;


-(id)initWithNibName:(NSString *)nibNameOrNil 
              bundle:(NSBundle *)nibBundleOrNil 
                isbn:(NSString *)aIsbn 
             profile:(SCHProfileItem *)aProfile;

// interface builder
- (IBAction)toolbarButtonPressed:(id)sender;
- (IBAction)storyInteractionAction:(id)sender;
- (IBAction)highlightsAction:(id)sender;
- (IBAction)notesAction:(id)sender;
- (IBAction)settingsAction:(UIButton *)sender;
- (IBAction)popViewController:(id)sender;
- (IBAction)audioPlayAction:(id)sender;

@end
