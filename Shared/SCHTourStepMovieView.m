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
    [movieURL release], movieURL = nil;
    [moviePlayer release], moviePlayer = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.tourImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)startVideo
{
    if (!self.movieURL) {
        return;
    }
    
    if (self.moviePlayer) {
        [self.moviePlayer stop];
        [self.moviePlayer.view setHidden:NO];
        [self.moviePlayer play];
        return;
    }
    
    self.moviePlayer = [[[MPMoviePlayerController alloc] initWithContentURL:self.movieURL] autorelease];
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.shouldAutoplay = NO;
    
    self.moviePlayer.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
//    CGFloat numViewPixelsToTrim  = 30.0f;
//    [self.currentMoviePlayer.view setFrame:CGRectMake(0, -numViewPixelsToTrim/2.0f, 556, 382 + numViewPixelsToTrim)];
    
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.contentView addSubview:self.moviePlayer.view];
    
    [self.moviePlayer play];

}

- (void)stopVideo
{
    if (self.moviePlayer) {
        [self.moviePlayer stop];
        [self.moviePlayer.view setHidden:YES];
    }
}

@end
