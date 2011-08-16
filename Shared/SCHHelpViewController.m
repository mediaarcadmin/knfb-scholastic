//
//  SCHHelpViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 16/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHHelpViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "SCHPlayButton.h"
#import "UIColor+Scholastic.h"
#import "SCHUserDefaults.h"

// Constants
static NSString * const kSCHHelpViewControllerYoungerVideo = @"youngerHelpVideo";
static NSString * const kSCHHelpViewControllerOlderVideo = @"olderHelpVideo";
static NSString * const kSCHHelpViewControllerVideoExtension = @"mp4";

static CGFloat const kSCHStoryInteractionControllerVideoCornerRadius = 8.0;
static CGFloat const kSCHStoryInteractionControllerVideoBorderWidth = 4.0;

@interface SCHHelpViewController ()

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, assign) BOOL youngerMode;
@property (nonatomic, assign) BOOL firstPlay;

- (void)releaseViewObjects;
- (void)pause;
- (void)play;
- (void)dismiss;

@end

@implementation SCHHelpViewController

@synthesize movieContainerView;
@synthesize playButton;
@synthesize closeButton;
@synthesize moviePlayer;
@synthesize youngerMode;
@synthesize firstPlay;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
          youngerMode:(BOOL)aYoungerMode;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        youngerMode = aYoungerMode;
        if (youngerMode == YES) {
            firstPlay = [[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsYoungerHelpVideoFirstPlay];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSCHUserDefaultsYoungerHelpVideoFirstPlay];
        } else {
            firstPlay = [[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsOlderHelpVideoFirstPlay];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSCHUserDefaultsOlderHelpVideoFirstPlay];            
        }
    }
    return(self);
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [movieContainerView release], movieContainerView = nil;
    [moviePlayer stop];
    [moviePlayer release], moviePlayer = nil;
    [playButton release], playButton = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.movieContainerView.layer.cornerRadius = kSCHStoryInteractionControllerVideoCornerRadius;  
        self.movieContainerView.layer.borderWidth = kSCHStoryInteractionControllerVideoBorderWidth; 
        if (self.youngerMode == NO) {
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
    
    if (self.firstPlay == YES) {
        self.closeButton.hidden = YES;
        self.playButton.hidden = YES;
    }
    
    self.playButton.actionBlock = ^(SCHPlayButton *button) {
        if (button.play == YES) {
            [self play];
        } else {
            [self pause];
        }
    };
    
    NSURL *movieURL = nil;
    if (self.youngerMode == YES) {
        movieURL = [[NSBundle mainBundle] URLForResource:kSCHHelpViewControllerYoungerVideo 
                                           withExtension:kSCHHelpViewControllerVideoExtension];   
    } else {
        movieURL = [[NSBundle mainBundle] URLForResource:kSCHHelpViewControllerOlderVideo 
                                           withExtension:kSCHHelpViewControllerVideoExtension];
    }
    
    if (movieURL) {
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        [self.moviePlayer prepareToPlay];
        self.moviePlayer.controlStyle = MPMovieControlStyleNone;
        self.moviePlayer.shouldAutoplay = self.firstPlay;
        [self.moviePlayer.view setFrame:self.movieContainerView.bounds];
        self.moviePlayer.view.autoresizingMask =  
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | 
        UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        [self.movieContainerView addSubview:self.moviePlayer.view];
        [self.moviePlayer release];
    }
    
    // register for going into the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

#pragma mark - Action methods

- (IBAction)closeAction:(id)sender
{
    [self dismiss];
}

- (void)dismiss
{
    self.playButton.actionBlock = nil;
    [self.moviePlayer stop];
    [self dismissModalViewControllerAnimated:YES];    
}

#pragma mark - Movie methods

- (void)pause
{
    [self.moviePlayer pause]; 
}

- (void)play
{
    [self.moviePlayer play];
}

#pragma mark - Notification methods

- (void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification *)notification
{
    if (notification.object == self.moviePlayer) {
        switch (self.moviePlayer.playbackState) {
            case MPMoviePlaybackStateStopped:
                break;
            case MPMoviePlaybackStatePaused:
                self.playButton.play = NO;
                if (self.moviePlayer.currentPlaybackTime >= self.moviePlayer.duration) {
                    if (self.firstPlay == YES) {
                        [self dismiss];
                    } else {
                    self.playButton.icon = SCHPlayButtonIconPlay;  
                    }
                }
                break;
            case MPMoviePlaybackStatePlaying:
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

@end
