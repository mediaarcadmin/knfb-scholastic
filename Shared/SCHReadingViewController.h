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
#import "SCHReadingViewNavigationToolbar.h"
#import "SCHHelpViewController.h"

extern NSString * const kSCHReadingViewErrorDomain;

typedef enum 
{
	kSCHReadingViewMissingParametersError = 0,
	kSCHReadingViewXPSCheckoutFailedError,
	kSCHReadingViewDecryptionUnavailableError,
    kSCHReadingViewUnspecifiedError
} SCHReadingViewError;

typedef enum 
{
	SCHReadingViewPaperTypeWhite = 0,
	SCHReadingViewPaperTypeBlack,
	SCHReadingViewPaperTypeSepia
} SCHReadingViewPaperType;

typedef enum 
{
    SCHReadingViewLayoutTypeUnspecified = 0,
	SCHReadingViewLayoutTypeFlow,
	SCHReadingViewLayoutTypeFixed
} SCHReadingViewLayoutType;

@class SCHCustomToolbar;
@class SCHProfileItem;
@class SCHBookIdentifier;
@class SCHReadingStoryInteractionButton;

@interface SCHReadingViewController : UIViewController <SCHReadingViewDelegate, SCHReadingNotesListControllerDelegate, 
SCHReadingNoteViewDelegate, SCHReadingInteractionsListControllerDelegate, SCHAudioBookPlayerDelegate, UIPopoverControllerDelegate,
SCHStoryInteractionControllerDelegate, SCHReadingViewNavigationToolbarDelegate, SCHHelpViewControllerDelegate> 
{}
UIImageView *optionsPhoneTopBackground;



@property (nonatomic, assign) BOOL youngerMode;

// interface builder
@property (nonatomic, retain) IBOutlet UIButton *notesButton;
@property (nonatomic, retain) IBOutlet UIButton *storyInteractionsListButton;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *scrubberToolbar;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *olderBottomToolbar;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *highlightsToolbar;
@property (nonatomic, retain) IBOutlet UIImageView *bottomShadow;

@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UIImageView *scrubberThumbImage;
@property (nonatomic, retain) IBOutlet UIView *scrubberInfoView;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;

@property (nonatomic, retain) IBOutlet UIView *optionsPhoneTopBackground;
@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) IBOutlet UIViewController *popoverOptionsViewController;
@property (nonatomic, retain) IBOutlet UIView *customOptionsView;
@property (nonatomic, retain) IBOutlet UILabel *popoverNavigationTitleLabel;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *originalButtons;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *customButtons;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *largeOptionsButtons;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *smallOptionsButtons;
@property (nonatomic, retain) IBOutlet UISegmentedControl *fontSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *paperTypeSegmentedControl;


@property (nonatomic, retain) IBOutlet SCHReadingStoryInteractionButton *storyInteractionButton;
@property (nonatomic, retain) IBOutlet UIView *storyInteractionButtonView;
@property (nonatomic, retain) IBOutlet UIView *toolbarToggleView;
@property (nonatomic, retain) IBOutlet UIView *cornerAudioButtonView;

@property (nonatomic, retain) IBOutlet UIButton *highlightsCancelButton;
@property (nonatomic, retain) IBOutlet UIButton *highlightsInfoButton;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(id)initWithNibName:(NSString *)nibNameOrNil 
              bundle:(NSBundle *)nibBundleOrNil 
      bookIdentifier:(SCHBookIdentifier *)aIdentifier 
             profile:(SCHProfileItem *)aProfile
managedObjectContext:(NSManagedObjectContext *)moc
               error:(NSError **)error;

// interface builder
- (IBAction)storyInteractionAction:(id)sender;
- (IBAction)highlightsAction:(id)sender;
- (IBAction)notesAction:(id)sender;
- (IBAction)settingsAction:(UIButton *)sender;
- (IBAction)paperTypeSegmentChanged:(UISegmentedControl *)segControl;

@end
