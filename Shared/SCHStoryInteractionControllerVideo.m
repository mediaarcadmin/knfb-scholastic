//
//  SCHStoryInteractionControllerVideo.m
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerVideo.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#import "SCHStoryInteractionVideo.h"
#import "SCHXPSProvider.h"
#import "SCHPlayButton.h"
#import "UIColor+Scholastic.h"

static CGFloat const kSCHStoryInteractionControllerVideoCornerRadius = 14.0;
static CGFloat const kSCHStoryInteractionControllerVideoBorderWidth = 4.0;

@interface SCHStoryInteractionControllerVideo ()

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

- (void)pause;
- (void)play;

@end

@implementation SCHStoryInteractionControllerVideo

@synthesize movieContainerView;
@synthesize playButton;
@synthesize moviePlayer;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [movieContainerView release], movieContainerView = nil;
    [moviePlayer stop];
    [moviePlayer release], moviePlayer = nil;
    
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{    
    [self setTitle:[(SCHStoryInteractionVideo *)self.storyInteraction videoTranscript]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.movieContainerView.layer.cornerRadius = kSCHStoryInteractionControllerVideoCornerRadius;  
        self.movieContainerView.layer.borderWidth = kSCHStoryInteractionControllerVideoBorderWidth; 
        if ([self.storyInteraction isOlderStoryInteraction] == YES) {
            self.movieContainerView.layer.borderColor = [[UIColor SCHPurple1Color] CGColor];    
        } else {
            self.movieContainerView.layer.borderColor = [[UIColor SCHBlue2Color] CGColor];    
        }        
        self.movieContainerView.layer.masksToBounds = YES;
        
        self.playButton.layer.cornerRadius = kSCHStoryInteractionControllerVideoCornerRadius;  
        self.playButton.layer.borderWidth = kSCHStoryInteractionControllerVideoBorderWidth; 
        self.playButton.layer.borderColor = self.movieContainerView.layer.borderColor;
        self.playButton.layer.masksToBounds = YES;
    }
    
    self.playButton.actionBlock = ^(SCHPlayButton *button) {
        if (button.play == YES) {
            [self play];
        } else {
            [self pause];
        }
    };
    
    NSURL *movieURL = nil;
    NSString *moviePath = [(SCHStoryInteractionVideo *)self.storyInteraction videoPath];
    if (moviePath) {
        movieURL = [self.xpsProvider temporaryURLForComponentAtPath:moviePath];
    }
    
    if (movieURL) {
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        self.moviePlayer = player;
        [player release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];

        [self.moviePlayer prepareToPlay];
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.shouldAutoplay = NO;
        [self.moviePlayer.view setFrame:self.movieContainerView.bounds];
        self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.movieContainerView addSubview:self.moviePlayer.view];
    }
    
    // register for going into the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        NSString *path = [self.storyInteraction audioPathForQuestion];
        if (path != nil) {
            [self pause];
            [self enqueueAudioWithPath:path fromBundle:NO];
        }   
    }];
}

- (void)pause
{
    [self.moviePlayer pause]; 
}

- (void)play
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self.moviePlayer play];
    }];
}

#pragma mark - Notification methods

- (void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification *)notification
{
    if (notification.object == self.moviePlayer) {
        switch (self.moviePlayer.playbackState) {
            case MPMoviePlaybackStateStopped:
            case MPMoviePlaybackStatePaused:
                self.playButton.play = NO;
                if (self.moviePlayer.currentPlaybackTime >= self.moviePlayer.duration) {
                    self.playButton.icon = SCHPlayButtonIconPlay;  
                }
                break;
            case MPMoviePlaybackStatePlaying:
                // Always mark as complete if the user plays the video
                self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
                self.playButton.play = YES;
                break;            
            case MPMoviePlaybackStateInterrupted:
                [self pause];
                break;
        }
    }
}

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self pause];
}

- (NSString *)audioPath
{
    return([(SCHStoryInteractionVideo *)self.storyInteraction audioPathForQuestion]);
}

- (SCHFrameStyle)frameStyle
{
    return(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? SCHStoryInteractionTitle : SCHStoryInteractionTransparentTitle);
}

- (void)closeButtonTapped:(id)sender
{
    self.playButton.actionBlock = nil;
    [self.moviePlayer stop];
    [super closeButtonTapped:sender];    
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // don't need to disable for this interaction
}

- (void)storyInteractionEnableUserInteraction
{
    // don't need to enable for this interaction
}



@end
