//
//  SCHStoryInteractionSequencing.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionSequencing.h"

@implementation SCHStoryInteractionSequencing

- (NSString *)title
{
    return @"Put the story in order of what happened first, next, and last.";
}

-(NSInteger)numberOfImages
{
    return 3;
}

- (NSString *)audioPathForQuestion
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_putinorder.mp3"];
}

- (NSString *)audioPathForCorrectAnswer
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"tada.mp3"];
}

- (NSString *)imagePathForIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_img%d.png", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswerAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end
