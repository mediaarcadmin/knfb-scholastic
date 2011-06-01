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
    return @"Sequencing";
}

-(NSInteger)numberOfImages
{
    return 3;
}

- (NSString *)audioPathForQuestion
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"gen_putinorder.mp3"];
}

- (NSString *)audioPathForCorrectAnswer
{
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:@"tada.mp3"];
}

- (NSString *)imagePathForIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_img%d.png", self.ID, index+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForCorrectAnswerAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_ca%d.mp3", self.ID, index+1];
    return [[SCHStoryInteraction resourcesPath] stringByAppendingPathComponent:filename];
}

@end
