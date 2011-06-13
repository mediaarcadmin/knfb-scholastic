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

static CGFloat const kSCHStoryInteractionControllerVideoCornerRadius = 14.0;
static CGFloat const kSCHStoryInteractionControllerVideoBorderWidth = 3.0;

@interface SCHStoryInteractionControllerVideo ()

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) NSString *movieFilePath;

- (void)pause;
- (void)play;

@end

@implementation SCHStoryInteractionControllerVideo

@synthesize movieContainerView;
@synthesize playButton;
@synthesize moviePlayer;
@synthesize movieFilePath;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [movieContainerView release], movieContainerView = nil;
    [moviePlayer stop];
    [moviePlayer release], moviePlayer = nil;
    [[NSFileManager defaultManager] removeItemAtPath:movieFilePath error:nil];
    [movieFilePath release], movieFilePath = nil;
    
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    NSArray  *applicationCachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *applicationCachePath = ([applicationCachePaths count] > 0) ? [applicationCachePaths objectAtIndex:0] : nil;
    
    [self setTitle:[(SCHStoryInteractionVideo *)self.storyInteraction videoTranscript]];
    
    self.movieContainerView.layer.cornerRadius = kSCHStoryInteractionControllerVideoCornerRadius;  
    self.movieContainerView.layer.borderWidth = kSCHStoryInteractionControllerVideoBorderWidth; 
    self.movieContainerView.layer.borderColor = [[UIColor colorWithRed:0.071 green:0.396 blue:0.698 alpha:1.000] CGColor];
    self.movieContainerView.layer.masksToBounds = YES;

    self.playButton.actionBlock = ^(SCHPlayButton *button) {
        if (button.play == YES) {
            [self play];
        } else {
            [self pause];
        }
    };
    
    if (applicationCachePath != nil) {
        NSString *moviePath = [(SCHStoryInteractionVideo *)self.storyInteraction videoPath];
        if(moviePath != nil) {
            self.movieFilePath = [applicationCachePath stringByAppendingPathComponent:[moviePath lastPathComponent]];            
                        
            NSData *movieData = [self.xpsProvider dataForComponentAtPath:moviePath];
            
            if (movieData != nil) {
                [movieData writeToFile:self.movieFilePath atomically:NO];
                self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.movieFilePath]];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                             name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                           object:nil];

                [self.moviePlayer prepareToPlay];
                self.moviePlayer.controlStyle = MPMovieControlStyleNone;
                self.moviePlayer.shouldAutoplay = NO;
                [self.moviePlayer.view setFrame:self.movieContainerView.bounds];
                [self.movieContainerView addSubview:self.moviePlayer.view];
                [self.moviePlayer release];
            } else {
                self.movieFilePath = nil;
            }            
        }
    }
    
    // register for going into the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    BOOL iWasPlaying = self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying;
    NSString *path = [self audioPath];
    if (path != nil) {
        [self pause];
        [self playAudioAtPath:path completion:^{
            if (iWasPlaying == YES) {
                [self play];
            }
        }];
    }   
}

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
            case MPMoviePlaybackStatePaused:
                self.playButton.play = NO;
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

- (NSString *)audioPath
{
    return([(SCHStoryInteractionVideo *)self.storyInteraction audioPathForQuestion]);
}

@end
