//
//  SCHStoryInteractionControllerImage.m
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerImage.h"

#import "SCHStoryInteractionImage.h"
#import "SCHXPSProvider.h"

@implementation SCHStoryInteractionControllerImage

@synthesize imageView;

- (void)dealloc
{
    [imageView release], imageView = nil;
    
    [super dealloc];
}

- (void)setupView
{
    NSString *imagePath = [(SCHStoryInteractionImage *)self.storyInteraction imagePath];
    NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
    self.imageView.image = [UIImage imageWithData:imageData];
}

- (BOOL)useAudioButton
{
    return(NO);
}

@end
