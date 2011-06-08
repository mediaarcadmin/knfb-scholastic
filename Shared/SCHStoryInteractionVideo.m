//
//  SCHStoryInteractionVideo.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionVideo.h"

#import "KNFBXPSConstants.h"

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

- (NSString *)videoPath
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:self.videoFilename];
}

@end
