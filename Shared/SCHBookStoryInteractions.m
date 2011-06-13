//
//  SCHBookStoryInteractions.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"

@interface SCHBookStoryInteractions ()
@property (nonatomic, retain) NSArray *storyInteractions;
@property (nonatomic, retain) NSDictionary *storyInteractionsByPage;
@end

@implementation SCHBookStoryInteractions

@synthesize storyInteractions;
@synthesize storyInteractionsByPage;

- (void)dealloc
{
    [storyInteractions release];
    [storyInteractionsByPage release];
    [super dealloc];
}

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider
{
    if ((self = [super init])) {
        // get the raw array of stories from the parser
        NSData *xml = [xpsProvider dataForComponentAtPath:KNFBXPSStoryInteractionsMetadataFile];
        SCHStoryInteractionParser *parser = [[SCHStoryInteractionParser alloc] init];
        self.storyInteractions = [parser parseStoryInteractionsFromData:xml];
        [parser release];
        
        // organise by page
        NSMutableDictionary *byPage = [[NSMutableDictionary alloc] init];
        for (SCHStoryInteraction *story in self.storyInteractions) {
            NSNumber *page = [NSNumber numberWithInteger:story.documentPageNumber];
            NSMutableArray *pageArray = [byPage objectForKey:page];
            if (!pageArray) {
                pageArray = [NSMutableArray array];
                [byPage setObject:pageArray forKey:page];
            }
            [pageArray addObject:story];
        }
        self.storyInteractionsByPage = [NSDictionary dictionaryWithDictionary:byPage];
        [byPage release];
    }
    return self;
}

- (NSArray *)allStoryInteractions
{
    return storyInteractions;
}

- (NSArray *)storyInteractionsForPage:(NSInteger)pageNumber
{
    return [self.storyInteractionsByPage objectForKey:[NSNumber numberWithInteger:pageNumber]];
}

@end