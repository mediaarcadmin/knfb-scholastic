//
//  SCHStoryInteractionPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 02/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionPictureStarter.h"

@implementation SCHStoryInteractionPictureStarter

@synthesize introductions;

- (void)dealloc
{
    [introductions release], introductions = nil;
    [super dealloc];
}

- (NSString *)introductionAtIndex:(NSInteger)index
{
    NSAssert(0 <= index && index <= [self.introductions count], @"bad index");
    return [self.introductions objectAtIndex:index];
}

- (NSString *)audioPathAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.mp3", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)imagePathAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_q%d.png", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end


@implementation SCHStoryInteractionPictureStarterCustom
@end