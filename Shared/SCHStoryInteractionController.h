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

// the current interface orientation; the hosting UIViewController should initialise this
// before presenting the view and update it as necessary
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

// a transparent hosting-view sized container for the story interaction views; if
// necessary gesture recognizers can be attached to this to collect events outside
// the main story interaction view
@property (nonatomic, retain) UIView *containerView;

// obtain a Controller for a StoryInteraction.
+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction;

// present the story interaction centered in the host view
- (void)presentInHostView:(UIView *)hostView;

// remove the story interaction from the host view; also sends storyInteractionControllerDidDismiss: to
// the delegate
- (void)removeFromHostView;

// switch to the next view in the NIB
- (void)presentNextScreen;

// play an audio file from the XPS provider and invoke a completion block when the playback is complete
- (BOOL)useAudioButton;
- (void)playAudioAtPath:(NSString *)path completion:(void(^)(void))completion;

// get an image from the XPS provider
- (UIImage *)imageAtPath:(NSString *)path;

#pragma mark - subclass overrides

// send then the nib is loaded and its view objects are attached to the container; similar
// to viewDidLoad, but used a separate message name to avoid confusion.
- (void)setupView;
- (NSString *)audioPath;

@end
