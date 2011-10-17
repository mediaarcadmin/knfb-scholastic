//
//  SCHStoryInteractionImage.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionImage.h"

#import "KNFBXPSConstants.h"

@implementation SCHStoryInteractionImage

@synthesize imageFilename;

- (void)dealloc
{
    [imageFilename release];
    [super dealloc];
}

- (NSString *)imagePath
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:self.imageFilename];
}

- (NSString *)title
{
    return @"Graphic";
}

- (BOOL)isOlderStoryInteraction
{
    return YES;
}

@end
