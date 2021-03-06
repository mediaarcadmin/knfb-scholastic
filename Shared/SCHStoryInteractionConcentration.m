//
//  SCHStoryInteractionConcentration.m
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionConcentration.h"

@implementation SCHStoryInteractionConcentration

@synthesize introduction;

- (void)dealloc
{
    [introduction release], introduction = nil;
    [super dealloc];
}

- (NSString *)title
{
    return @"Memory Match";
}

- (NSInteger)numberOfPairs
{
    return 12;
}

- (NSString *)audioPathForQuestion
{
    NSString *filename = [NSString stringWithFormat:@"%@_intro.mp3", self.ID];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)audioPathForIntroduction
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_memorymatch.mp3"];
}

- (NSString *)audioPathForYouWon
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_youwon.mp3"];
}

- (NSString *)imagePathForFirstOfPairAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_match%da.png", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];    
}

- (NSString *)imagePathForSecondOfPairAtIndex:(NSInteger)index
{
    NSString *filename = [NSString stringWithFormat:@"%@_match%db.png", self.ID, index+1];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];    
}

@end
