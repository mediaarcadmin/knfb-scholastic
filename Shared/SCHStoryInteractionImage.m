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

- (NSString *)audioPathForQuestion
{
    if ([self isOlderStoryInteraction] == YES) {
        return nil;
    } else {
        NSString *filename = [NSString stringWithFormat:@"%@_intro1.mp3", self.ID];
        return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
    }
}

- (NSString *)title
{
    return @"Graphic";
}

@end
