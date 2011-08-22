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
    NSString *filename = [NSString stringWithFormat:@"ollie_q%d.mp3", index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)imagePathAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"ollie_q%d.png", index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end


@implementation SCHStoryInteractionPictureStarterCustom
@end

@implementation SCHStoryInteractionPictureStarterNewEnding
@end

@implementation SCHStoryInteractionPictureStarterFavorite
@end