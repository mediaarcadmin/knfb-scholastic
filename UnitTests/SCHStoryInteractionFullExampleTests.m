//
//  SCHStoryInteractionFullExampleTests.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionAboutYouQuiz.h"
#import "SCHStoryInteractionHotSpot.h"
#import "SCHStoryInteractionMultipleChoice.h"
#import "SCHStoryInteractionPopQuiz.h"
#import "SCHStoryInteractionScratchAndSee.h"
#import "SCHStoryInteractionSequencing.h"
#import "SCHStoryInteractionStartingLetter.h"
#import "SCHStoryInteractionTitleTwister.h"
#import "SCHStoryInteractionVideo.h"
#import "SCHStoryInteractionWhoSaidIt.h"
#import "SCHStoryInteractionWordMatch.h"
#import "SCHStoryInteractionWordScrambler.h"
#import "SCHStoryInteractionWordSearch.h"

@interface SCHStoryInteractionFullExampleTests : SenTestCase {}
@property (nonatomic, retain) SCHStoryInteractionParser *parser;
@end

@implementation SCHStoryInteractionFullExampleTests

@synthesize parser;

- (void)setUp
{
    [super setUp];
    self.parser = [[[SCHStoryInteractionParser alloc] init] autorelease];
}

- (void)tearDown
{
    self.parser = nil;
    [super tearDown];
}

- (void)checkFile:(NSString *)suffix hasStories:(Class)firstStoryClass,...
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"];
    NSString *filename = [@"StoryInteractions" stringByAppendingString:suffix];
    NSString *path = [bundle pathForResource:filename ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(data, @"failed to load XML from %@", filename);
    NSArray *stories = [self.parser parseStoryInteractionsFromData:data];
    
    STAssertTrue([stories count] > 0, @"no stories found!");
    if ([stories count] == 0) {
        return;
    }
    
    STAssertTrue([[stories objectAtIndex:0] isKindOfClass:firstStoryClass], @"incorrect story type");
    
    va_list va_args;
    va_start(va_args, firstStoryClass);
    for (NSInteger index = 1; ; ++index) {
        Class storyClass = va_arg(va_args, Class);
        if (storyClass == nil) {
            break;
        }
        STAssertTrue(index < [stories count], @"too few stories in array");
        if (index >= [stories count]) {
            break;
        }
        STAssertTrue([[stories objectAtIndex:index] isKindOfClass:storyClass], @"incorrect story type");
    }
    
    va_end(va_args);
}

- (void)testFullExample1
{
    [self checkFile:@"FullExample1" hasStories:
     [SCHStoryInteractionTitleTwister class],
     [SCHStoryInteractionPopQuiz class],
     [SCHStoryInteractionWordScrambler class],
     [SCHStoryInteractionWhoSaidIt class],
     [SCHStoryInteractionAboutYouQuiz class],
     [SCHStoryInteractionWordScrambler class],
     [SCHStoryInteractionTitleTwister class],
     nil];
}

- (void)testFullExample2
{
    [self checkFile:@"FullExample2" hasStories:
     [SCHStoryInteractionWordScrambler class],
     [SCHStoryInteractionPopQuiz class],
     [SCHStoryInteractionTitleTwister class],
     [SCHStoryInteractionWordScrambler class],
     [SCHStoryInteractionTitleTwister class],
     [SCHStoryInteractionWordScrambler class],
     [SCHStoryInteractionWhoSaidIt class],
     nil];
}

- (void)testFullExample3
{
    [self checkFile:@"FullExample3" hasStories:
     [SCHStoryInteractionScratchAndSee class],
     [SCHStoryInteractionWordMatch class],
     [SCHStoryInteractionStartingLetter class],
     [SCHStoryInteractionMultipleChoiceWithAnswerPictures class],
     [SCHStoryInteractionSequencing class],
     nil];
}

- (void)testFullExample4
{
    [self checkFile:@"FullExample4" hasStories:
     [SCHStoryInteractionWordMatch class],
     [SCHStoryInteractionScratchAndSee class],
     [SCHStoryInteractionWordSearch class],
     [SCHStoryInteractionStartingLetter class],
     [SCHStoryInteractionMultipleChoiceText class],
     [SCHStoryInteractionHotSpot class],
     [SCHStoryInteractionMultipleChoiceText class],
     [SCHStoryInteractionWordSearch class],
     [SCHStoryInteractionVideo class],
     nil];
}

@end
