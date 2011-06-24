//
//  SCHStoryInteractionController.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVAudioPlayer.h>

@class SCHXPSProvider;
@class SCHStoryInteraction;
@protocol SCHStoryInteractionControllerDelegate;

typedef enum 
{
	SCHStoryInteractionTitle,
    SCHStoryInteractionTransparentTitle,
    SCHStoryInteractionNoTitle,
    SCHStoryInteractionFullScreen,
    SCHStoryInteractionTitleOverlaysContents
} SCHFrameStyle;
    
// Core presentation functionality for story interactions. 

// Because Story Interactions have a non-modal behaviour in the reading view, StoryInteractionController 
// is not a UIViewController but relies on another view and controller as hosts.

@interface SCHStoryInteractionController : NSObject <AVAudioPlayerDelegate> {}

// Unique Book Identifier
@property (nonatomic, copy) NSString *isbn;

// XPS Provider for this story's book
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;

// the story interaction model for this controller
@property (nonatomic, readonly) SCHStoryInteraction *storyInteraction;

// the delegate for this controller; should probably be the UIViewController of the
// hosting view
@property (nonatomic, assign) id<SCHStoryInteractionControllerDelegate> delegate;

// a transparent hosting-view sized container for the story interaction views; if
// necessary gesture recognizers can be attached to this to collect events outside
// the main story interaction view
@property (nonatomic, retain) UIView *containerView;

// The current contents view (loaded from a nib)
@property (nonatomic, retain) UIView *contentsView;

@property (nonatomic, retain) UILabel *titleView;

// setup the title text
- (void)setupTitle;

// rotation about to occur
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

// rotation complete
- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

// obtain a Controller for a StoryInteraction.
+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction;

// present the story interaction centered in the host view
- (void)presentInHostView:(UIView *)hostView withInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// action when tapping the close button
- (void)closeButtonTapped:(id)sender;

// remove the story interaction from the host view; also sends storyInteractionControllerDidDismiss: to
// the delegate
- (void)removeFromHostViewWithSuccess:(BOOL)success;

// switch to the next view in the NIB
- (void)presentNextView;

// play an audio file from the XPS provider and invoke a completion block when the playback is complete
- (void)playAudioAtPath:(NSString *)path completion:(void(^)(void))completion;

// playing audio files from the app bundle
- (void)playBundleAudioWithFilename:(NSString *)path completion:(void (^)(void))completion;

// currently playing audio?
- (BOOL)playingAudio;

// enqueue an audio file (either from bundle or XPSProvider) with blocks to execute synchronized with
// the start and end of the audio
- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock;

// convenience version of above with no delay and no synchronized blocks
- (void)enqueueAudioWithPath:(NSString *)path fromBundle:(BOOL)fromBundle;

// cancel any playing or queued audio
- (void)cancelQueuedAudio;

// cancel any playing or queued audio, but still execute the synchronized blocks for any
// pending audio items; the blocks will be executed synchronously and immediately
- (void)cancelQueuedAudioExecutingSynchronizedBlocksImmediately;

// get an image from the XPS provider
- (UIImage *)imageAtPath:(NSString *)path;

// set the title for the story interaction
- (void)setTitle:(NSString *)title;

// view is oriented in landscape as expected for story interactions?
- (BOOL)isLandscape;

// get an affine transform for the current interface orientation; this will translate points
// in the current view to the expected landscape orientation for story interactions
- (CGAffineTransform)affineTransformForCurrentOrientation;

#pragma mark - subclass overrides

// The frame styling used
@property (nonatomic, readonly) SCHFrameStyle frameStyle;

// when frameStyle == SCHStoryInteractionTitleOverlaysContents, the subclass can define
// the frame for the overlaid title view
- (CGRect)overlaidTitleFrame;

// send then the nib is loaded and its view objects are attached to the container; similar
// to viewDidLoad, but used a separate message name to avoid confusion.
- (void)setupViewAtIndex:(NSInteger)screenIndex;

// normally the question audio (if any) is played when the view appears; override
// to change this behaviour
- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex;

// audio path for current question - default implementation uses audioPathForQuestion
// from the story interaction; override if variable audio per question is needed
- (NSString *)audioPathForQuestion;

// Story interactions can use this to disable interactions
// also disables superview user interactions, as interactions are passed through
// with great power comes great responsibility - use carefully!
- (void)setUserInteractionsEnabled:(BOOL)enabled;

// The user tapped the play audio button in the top right corner; default behaviour is
// to repeat the question defined by [self audioPathForQuestion].
- (IBAction)playAudioButtonTapped:(id)sender;

@end
