//
//  SCHStoryInteractionJigsaw.m
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsaw.h"

@implementation SCHStoryInteractionJigsaw

- (id)init
{
    return [super init];
}

- (NSString *)title
{
    return @"Jigsaw";
}

- (BOOL)isOlderStoryInteraction
{
    return NO;
}

- (NSString *)imagePathForPuzzle
{
    NSString *filename = [NSString stringWithFormat:@"%@_medium.png", self.ID];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForChooseYourPuzzle
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_chooseyourpuzzle.mp3"];
}

- (NSString *)audioPathForClickPuzzleToStart
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_clickthepuzzle.mp3"];
}

@end