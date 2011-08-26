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

- (NSString *)interactionViewTitle
{
    return @"Picture Starter";
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

- (NSString *)audioPathForClearThisPicture
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_clearpicture.mp3"];
}

@end


@implementation SCHStoryInteractionPictureStarterCustom

- (NSString *)audioPathForChooseYourPicture
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_chooseyourpicture.mp3"];
}

@end

@implementation SCHStoryInteractionPictureStarterNewEnding
@end

@implementation SCHStoryInteractionPictureStarterFavorite
@end