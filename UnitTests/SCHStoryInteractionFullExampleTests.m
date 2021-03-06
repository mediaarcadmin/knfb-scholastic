//
//  SCHStoryInteractionFullExampleTests.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionTypes.h"

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
            STAssertTrue(index == [stories count], @"too many stories");
            break;
        }
        STAssertTrue(index < [stories count], @"too few stories in array");
        if (index >= [stories count]) {
            break;
        }
        STAssertEquals([[stories objectAtIndex:index] class], storyClass, @"incorrect story type");
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
     [SCHStoryInteractionCardCollection class],
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
     [SCHStoryInteractionImage class],
     nil];
}

- (void)testFullExample3
{
    [self checkFile:@"FullExample3" hasStories:
     [SCHStoryInteractionPictureStarterCustom class],
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
     [SCHStoryInteractionPictureStarterNewEnding class],
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
