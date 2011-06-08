//
//  SCHStoryInteractionControllerVideo.m
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerVideo.h"

#import "SCHStoryInteractionVideo.h"
#import "SCHXPSProvider.h"

@implementation SCHStoryInteractionControllerVideo

@synthesize movieView;

- (void)dealloc
{
    [movieView release], movieView = nil;
    
    [super dealloc];
}

- (void)setupView
{
    NSString *moviePath = [(SCHStoryInteractionVideo *)self.storyInteraction videoPath];
    NSData *movieData = [self.xpsProvider dataForComponentAtPath:moviePath];
    [movieData class];
//    self.movieView.image = [UIImage imageWithData:imageData];
}

- (BOOL)useAudioButton
{
    return(NO);
}

@end
