//
//  SCHStoryInteractionVideo.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionVideo.h"

#import "KNFBXPSConstants.h"
#import "SCHBookStoryInteractions.h"

@implementation SCHStoryInteractionVideo

@synthesize videoTranscript;
@synthesize videoFilename;

- (void)dealloc
{
    [videoTranscript release];
    [videoFilename release];
    [super dealloc];
}

- (NSString *)title
{
    return @"Video";
}

- (NSString *)audioPathForQuestion
{
    NSUInteger videoIndex = [[self.bookStoryInteractions storyInteractionsOfClass:[self class]] indexOfObject:self];
    NSString *filename = [NSString stringWithFormat:@"%@_intro%lu.mp3", self.ID, videoIndex + 1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)videoPath
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:self.videoFilename];
}

@end
