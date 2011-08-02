//
//  SCHStoryInteractionCardCollection.m
//  Scholastic
//
//  Created by Neil Gall on 02/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionCardCollection.h"

@implementation SCHStoryInteractionCardCollectionCard

@synthesize frontFilename;
@synthesize backFilename;

- (void)dealloc
{
    [frontFilename release], frontFilename = nil;
    [backFilename release], backFilename = nil;
    [super dealloc];
}

@end

@implementation SCHStoryInteractionCardCollection

@synthesize headerFilename;
@synthesize cards;

- (void)dealloc
{
    [headerFilename release], headerFilename = nil;
    [cards release], cards = nil;
    [super dealloc];
}

- (NSString *)imagePathForHeader
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:self.headerFilename];
}

- (NSInteger)numberOfCards
{
    return [self.cards count];
}

- (NSString *)imagePathForCardFrontAtIndex:(NSInteger)index
{
    NSString *filename = [[self.cards objectAtIndex:index] frontFilename];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

- (NSString *)imagePathForCardBackAtIndex:(NSInteger)index
{
    NSString *filename = [[self.cards objectAtIndex:index] backFilename];
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
}

@end
