//
//  SCHTourStepMovieView.m
//  Scholastic
//
//  Created by Gordon Christie on 01/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepMovieView.h"
#import <MediaPlayer/MPMoviePlayerController.h>


@interface SCHTourStepMovieView ()

@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

@end

@implementation SCHTourStepMovieView

@synthesize movieURL;
@synthesize moviePlayer;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [movieURL release], movieURL = nil;
    [moviePlayer release], moviePlayer = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame bottomBarVisible:(BOOL)bottomBarVisible
{
    self = [super initWithFrame:frame bottomBarVisible:bottomBarVisible];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMovieStatus:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    }
    return self;
}

- (void)checkMovieStatus:(NSNotification *)note {
    if (moviePlayer.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK))
    {
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.tourImageView.alpha = 0.9f;
                             self.moviePlayer.view.alpha = 1;
                         } completion:^(BOOL finished) {
                             [self.contentView bringSubviewToFront:self.moviePlayer.view];
                             self.tourImageView.alpha = 1;
                         }];
    }
}

- (void)startVideo
{
    if (!self.movieURL) {
        return;
    }
    
    if (self.moviePlayer) {
        if ([self.moviePlayer playbackState] == MPMoviePlaybackStatePlaying) {
            [self.moviePlayer setCurrentPlaybackTime:0.0f];
        } else {
            [self.moviePlayer play];
        }
        
        return;
    }
    
    self.moviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:self.movieURL] autorelease];
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    
    self.moviePlayer.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    self.moviePlayer.view.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.contentView addSubview:self.moviePlayer.view];
    [self.contentView bringSubviewToFront:self.tourImageView];

    [self.moviePlayer play];

}

- (void)stopVideo
{
    // animations here to prevent a black flicker when the movie stops
    if (self.moviePlayer) {
        self.tourImageView.alpha = 0.9f;
        [self.contentView bringSubviewToFront:self.tourImageView];
        [self.moviePlayer pause];
        [UIView animateWithDuration:0.1
                         animations:^{
                             self.moviePlayer.view.alpha = 0.9f;
                             self.tourImageView.alpha = 1;
                         } completion:^(BOOL finished) {
                             self.tourImageView.alpha = 1;
                             self.moviePlayer.view.alpha = 0.9f;
                             [self.moviePlayer stop];
                             [self.moviePlayer.view removeFromSuperview];
                             self.moviePlayer = nil;
                         }];
    }
}

@end
