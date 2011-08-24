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

static CGFloat const kSCHStoryInteractionControllerVideoCornerRadius = 20.0;
static CGFloat const kSCHStoryInteractionControllerVideoBorderWidth = 4.0;
static CGFloat const kSCHStoryInteractionControllerCloseCornerRadius = 8.0;
static CGFloat const kSCHStoryInteractionControllerCloseBorderWidth = 1.5;


@interface SCHHelpViewController ()

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, assign) BOOL youngerMode;
@property (nonatomic, assign) BOOL firstPlay;
@property (nonatomic, assign) BOOL statusBarHiddenOnEntry;

- (void)releaseViewObjects;
- (void)pause;
- (void)play;
- (void)dismiss;

@end

@implementation SCHHelpViewController

@synthesize movieContainerView;
@synthesize borderView;
@synthesize playButton;
@synthesize closeButton;
@synthesize moviePlayer;
@synthesize youngerMode;
@synthesize firstPlay;
@synthesize statusBarHiddenOnEntry;

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
    [borderView release], borderView = nil;
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
        
    self.closeButton.alpha = 0.4f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.wantsFullScreenLayout = YES;
    } else {
        self.closeButton.layer.cornerRadius = kSCHStoryInteractionControllerCloseCornerRadius;  
        self.closeButton.layer.borderWidth = kSCHStoryInteractionControllerCloseBorderWidth;
        self.closeButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    
    self.borderView.layer.cornerRadius = kSCHStoryInteractionControllerVideoCornerRadius;  
    self.borderView.layer.borderWidth = kSCHStoryInteractionControllerVideoBorderWidth;
        
    if (self.youngerMode == NO) {
        self.borderView.layer.borderColor = [[UIColor SCHPurple1Color] CGColor];    
    } else {
        self.borderView.layer.borderColor = [[UIColor SCHBlue2Color] CGColor];    
    }                
    
    [self.playButton setPlay:YES animated:NO]; // We always want help to start playing
    
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
        self.moviePlayer.shouldAutoplay = YES;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.statusBarHiddenOnEntry = [[UIApplication sharedApplication] isStatusBarHidden];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHiddenOnEntry];
    }
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
