//
//  SCHStoryInteractionImage.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionImage.h"


@implementation SCHStoryInteractionImage

@synthesize imageFilename;

- (void)dealloc
{
    [imageFilename release];
    [super dealloc];
}

- (NSString *)imagePath
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:self.imageFilename];
}

@end
