//
//  SCHStoryInteractionController.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "SCHStoryInteraction.h"

@class SCHXPSProvider;
@class SCHStoryInteraction;
@class SCHBookIdentifier;
@class SCHStoryInteractionController;

@protocol SCHStoryInteractionControllerDelegate;

@protocol SCHStoryInteractionControllerStateReactions <NSObject>

- (void)storyInteractionDisableUserInteraction;
- (void)storyInteractionEnableUserInteraction;

@end

typedef enum
{
    SCHStoryInteractionControllerStateInitialised,                          // the default initialised state
    SCHStoryInteractionControllerStateAskingOpeningQuestion,                // during the initial question audio
    SCHStoryInteractionControllerStateInteractionInProgress,                // user interaction is happening normally
    SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause,    // user interaction is paused while an answer is read out
    SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause, // answer is read out, and the audio button is disabled, but user interaction still enabled
    SCHStoryInteractionControllerStateInteractionFinishedSuccessfully       // user interaction has been completed successfully
} SCHStoryInteractionControllerState;

typedef enum 
{
	SCHStoryInteractionTitle,
    SCHStoryInteractionTransparentTitle,
    SCHStoryInteractionNoTitle,
    SCHStoryInteractionFullScreen,
    SCHStoryInteractionTitleOverlaysContentsAtTop,
    SCHStoryInteractionTitleOverlaysContentsAtBottom
} SCHFrameStyle;

// on SIs with multiple answer buttons, any selections within this
// time (in seconds) are assumed to be simultaneous taps and ignored
#define kMinimumDistinguishedAnswerDelay 0.2

// Core presentation functionality for story interactions. 

// Because Story Interactions have a non-modal behaviour in the reading view, StoryInteractionController 
// is not a UIViewController but relies on another view and controller as hosts.

@interface SCHStoryInteractionController : NSObject <AVAudioPlayerDelegate, SCHStoryInteractionControllerStateReactions> {}

// Unique Book Identifier
@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

// XPS Provider for this story's book
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;

// the story interaction model for this controller
@property (nonatomic, readonly) SCHStoryInteraction *storyInteraction;

// the delegate for this controller; should probably be the UIViewController of the
// hosting view
@property (nonatomic, assign) id<SCHStoryInteractionControllerDelegate> delegate;

// assuming the SI is associated with a pair of adjacent pages, which ones are currently visible
@property (nonatomic, assign) enum SCHStoryInteractionQuestionPageAssociation pageAssociation;

// the current mode of the story interaction
@property (nonatomic, assign) SCHStoryInteractionControllerState controllerState;

// a transparent hosting-view sized container for the story interaction views; if
// necessary gesture recognizers can be attached to this to collect events outside
// the main story interaction view
@property (nonatomic, retain) UIView *containerView;

// The current contents view (loaded from a nib)
@property (nonatomic, retain) UIView *contentsView;

@property (nonatomic, retain) UILabel *titleView;

// the current interface orientation
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

// the view containing this Story Interaction
- (UIView *)hostView;

// setup the title text
- (void)setupTitle;

// obtain a Controller for a StoryInteraction.
+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction;

// present the story interaction centered in the host view
- (void)presentInHostView:(UIView *)hostView withInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// call before autorotatiopn
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

// call after autorotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

// action when tapping the close button
- (void)closeButtonTapped:(id)sender;

// FIXME: this sends storyInteractionControllerWillDismiss:withSuccess: to the delegate - needed for unconverted interactions
- (void)didSuccessfullyCompleteInteraction;

// remove the story interaction from the host view; also sends storyInteractionControllerDidDismiss: to
// the delegate
- (void)removeFromHostView;

// switch to the next view in the NIB
- (void)presentNextView;

// resize the existing content view
- (void)resizeCurrentViewToSize:(CGSize)newSize animationDuration:(NSTimeInterval)animationDuration withAdditionalAdjustments:(dispatch_block_t)adjustmentBlock;

// currently playing audio?
- (BOOL)playingAudio;

// enqueue an audio file (either from bundle or XPSProvider) with blocks to execute synchronized with
// the start and end of the audio
- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock
          requiresEmptyQueue:(BOOL)requiresEmpty;

// convenience version of above with requiresEmpty NO
- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock;

// convenience version of above with no delay and no synchronized blocks
- (void)enqueueAudioWithPath:(NSString *)path fromBundle:(BOOL)fromBundle;

// cancel any playing or queued audio, but still execute the synchronized blocks for any
// pending audio items; the blocks are executed asynchronously, but before the supplied
// (and optional) completion handler;
- (void)cancelQueuedAudioExecutingSynchronizedBlocksBefore:(dispatch_block_t)completion;

// get an image from the XPS provider
- (UIImage *)imageAtPath:(NSString *)path;

// audio path for "you found them all" - this appears to vary per XPS
- (NSString *)audioPathForYouFoundThemAll;

// set the title for the story interaction
- (void)setTitle:(NSString *)title;

// Story interactions can use this to disable interactions
// also disables superview user interactions, as interactions are passed through
// with great power comes great responsibility - use carefully!
- (void)setUserInteractionsEnabled:(BOOL)enabled;

// The current state of setUserInteractionsEnabled
- (BOOL)isUserInteractionsEnabled;

#pragma mark - subclass overrides

// The frame styling used (deprecated; use frameStyleForViewAtIndex: instead
@property (nonatomic, readonly) SCHFrameStyle frameStyle;

// frame-style for a view in the nib
- (SCHFrameStyle)frameStyleForViewAtIndex:(NSInteger)viewIndex;

// when frameStyle == SCHStoryInteractionTitleOverlaysContents, the subclass can define
// the frame for the overlaid title view
- (CGRect)overlaidTitleFrame;

// YES (default) if a snapshot of the reading view should be shown as a background to this SI
- (BOOL)shouldShowSnapshotOfReadingViewInBackground;

// should the transition between successive views be animated? defaults to YES on iPad, NO on iPhone
- (BOOL)shouldAnimateTransitionBetweenViews;

// send then the nib is loaded and its view objects are attached to the container; similar
// to viewDidLoad, but used a separate message name to avoid confusion.
- (void)setupViewAtIndex:(NSInteger)screenIndex;

// override to return NO if the story interaction should not show the top-left close button
- (BOOL)shouldShowCloseButtonForViewAtIndex:(NSInteger)screenIndex;

// normally the question audio (if any) is played when the view appears; override
// to change this behaviour
- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex;

// audio path for current question - default implementation uses audioPathForQuestion
// from the story interaction; override if variable audio per question is needed
- (NSString *)audioPathForQuestion;

// The user tapped the play audio button in the top right corner; default behaviour is
// to repeat the question defined by [self audioPathForQuestion].
- (IBAction)playAudioButtonTapped:(id)sender;

// Override this for a simpler alternative to willRotateToInterfaceOrientation:duration;
// This method is called in the rotation animation block so any adjustments will automatically
// be animated with the rotation.
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

// Override to specify custom iPad contents size for a given orientation
- (CGSize)iPadContentsSizeForOrientation:(UIInterfaceOrientation)orientation;

@end
