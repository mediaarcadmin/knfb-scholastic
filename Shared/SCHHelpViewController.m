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
#import "SCHHelpManager.h"
#import "Reachability.h"

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
@property (nonatomic, assign) BOOL statusBarHiddenOnEntry;

- (void)loadVideo;
- (void)releaseViewObjects;
- (void)pause;
- (void)play;
- (void)dismiss;
- (void)checkVideoDownload;

@end

@implementation SCHHelpViewController

@synthesize movieContainerView;
@synthesize playButton;
@synthesize closeButton;
@synthesize moviePlayer;
@synthesize youngerMode;
@synthesize statusBarHiddenOnEntry;
@synthesize delegate;
@synthesize loadingView;
@synthesize progressView;
@synthesize wifiView;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
          youngerMode:(BOOL)aYoungerMode;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        youngerMode = aYoungerMode;
    }
    return(self);
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [loadingView release], loadingView = nil;
    [progressView release], progressView = nil;
    [movieContainerView release], movieContainerView = nil;
    [moviePlayer stop];
    [moviePlayer release], moviePlayer = nil;
    [playButton release], playButton = nil;
    [wifiView release], wifiView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    self.closeButton.alpha = 0.4f;
    self.wantsFullScreenLayout = YES;
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if (iPad) {
        self.closeButton.layer.cornerRadius = kSCHStoryInteractionControllerCloseCornerRadius;  
        self.closeButton.layer.borderWidth = kSCHStoryInteractionControllerCloseBorderWidth;
        self.closeButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
        
    self.playButton.icon = SCHPlayButtonIconNone;
    
    __block SCHHelpViewController *weakSelf = self;
    
    self.playButton.actionBlock = ^(SCHPlayButton *button) {
        if (button.play == YES) {
            [weakSelf play];
        } else {
            [weakSelf pause];
        }
    };
    
    [self checkVideoDownload];
}


- (void)loadVideo
{
    NSURL *movieURL = nil;
    NSString *fileURL = nil;
    
    if (self.youngerMode) {
        fileURL = [[SCHHelpManager sharedHelpManager] helpVideoYoungerURL];
    } else {
        fileURL = [[SCHHelpManager sharedHelpManager] helpVideoOlderURL];
    }
    
    NSString *filename = [fileURL lastPathComponent];
    NSString *filePath = [[SCHHelpManager sharedHelpManager] helpVideoDirectory];
    movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", filePath, filename]];
    
    if (movieURL) {
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        self.moviePlayer = player;
        [player release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerPlaybackStateDidFinishNotification:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
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
    
    self.statusBarHiddenOnEntry = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHiddenOnEntry];
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
    self.playButton.actionBlock = nil;
    
    if (self.moviePlayer.playbackState != MPMoviePlaybackStateStopped) {
        [self.moviePlayer stop]; // The moviePlayerPlaybackStateDidFinishNotification will call dismiss
    } else {
        [self dismiss];
    }
}

- (void)dismiss
{
    [self dismissModalViewControllerAnimated:YES];   
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(helpViewWillClose:)]) {
        [self.delegate helpViewWillClose:self];
    }
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
                    self.playButton.icon = SCHPlayButtonIconPlay;  
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

- (void)moviePlayerPlaybackStateDidFinishNotification:(NSNotification *)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if (reason && ([reason intValue] == MPMovieFinishReasonPlaybackEnded)) {
        [self dismiss];
    }
}


- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self pause];
}

- (void)helpVideoDownloadPercentageUpdate:(NSNotification *)note
{
    NSDictionary *userInfo = [note userInfo];
    NSNumber *currentPercentage = [userInfo objectForKey:@"currentPercentage"];
    
    if (currentPercentage != nil) {
        if ([currentPercentage floatValue] == 1) {
            self.loadingView.hidden = YES;
            self.wifiView.hidden = YES;
            self.playButton.userInteractionEnabled = YES;
            [self loadVideo];
        } else {
            self.progressView.progress = [currentPercentage floatValue];
        }
    }
}

- (void)checkVideoDownload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kReachabilityChangedNotification 
                                                  object:nil];
    
    if ([[SCHHelpManager sharedHelpManager] haveHelpVideosDownloaded]) {
        self.loadingView.hidden = YES;
        self.wifiView.hidden = YES;
        self.playButton.userInteractionEnabled = YES;
        [self loadVideo];
        
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityNotification:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        
        self.playButton.userInteractionEnabled = NO;
        
        BOOL reachable = [[Reachability reachabilityForLocalWiFi] isReachable];
        
        if (reachable) {
            self.wifiView.hidden = YES;
            self.loadingView.hidden = NO;
            [[SCHHelpManager sharedHelpManager] retryHelpDownload];
            self.progressView.progress = [[SCHHelpManager sharedHelpManager] currentHelpVideoDownloadPercentage];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHHelpDownloadPercentageUpdate object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpVideoDownloadPercentageUpdate:) name:kSCHHelpDownloadPercentageUpdate object:nil];
        } else {
            self.wifiView.hidden = NO;
            self.loadingView.hidden = YES;
        }        
    }
}

- (void)reachabilityNotification:(NSNotification *)note
{
    [self checkVideoDownload];
}

@end
