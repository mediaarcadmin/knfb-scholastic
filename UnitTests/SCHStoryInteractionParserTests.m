//
//  UnitTests.m
//  UnitTests
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionHotSpot.h"
#import "SCHStoryInteractionMultipleChoice.h"
#import "SCHStoryInteractionPopQuiz.h"
#import "SCHStoryInteractionScratchAndSee.h"

@interface SCHStoryInteractionParserTests : SenTestCase {}
@property (nonatomic, retain) SCHStoryInteractionParser *parser;
@end


@implementation SCHStoryInteractionParserTests

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

- (NSArray *)parse:(NSString *)suffix
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"];
    NSString *filename = [@"StoryInteraction" stringByAppendingString:suffix];
    NSString *path = [bundle pathForResource:filename ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    STAssertNotNil(data, @"failed to load XML from %@", filename);
    return [self.parser parseStoryInteractionsFromData:data];
}

- (void)testHotSpot1
{
    NSArray *stories = [self parse:@"HotSpot1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionHotSpot class]], @"incorrect class");
    
    SCHStoryInteractionHotSpot *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 28, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(188, 50)), @"incorrect position %@ should be 180,50", NSStringFromCGPoint(story.position));
    
    struct {
        NSString *prompt;
        CGRect hotSpotRect;
        CGSize originalBookSize;
    } expect[] = {
        { @"It looks like Ollie was knitting a new sock. Can you find it?", CGRectMake(256.2, 673.2, 102.0, 56.4), CGSizeMake(806, 606.23) },
        { @"Find something Ollie wears when he does magic tricks.", CGRectMake(460.9, 596.8, 78.9, 70.8), CGSizeMake(806, 606.23) },
        { @"Now find Ollie’s green origami project.", CGRectMake(273.5, 733.7, 64.5, 49.1), CGSizeMake(806, 606.23) }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);

    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionHotSpotQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertTrue(CGRectEqualToRect(q.hotSpotRect, expect[i].hotSpotRect), @"incorrect hotSpotRect for question %d", i+1);
        STAssertTrue(CGSizeEqualToSize(q.originalBookSize, expect[i].originalBookSize), @"incorrect originalBookSize for question %d", i+1);
    }
}

- (void)testMultipleChoice1
{
    NSArray *stories = [self parse:@"MultipleChoiceText1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionMultipleChoice class]], @"incorrect class");
    
    SCHStoryInteractionMultipleChoice *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 26, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(188, 100)), @"incorrect position");
    STAssertEqualObjects(story.introduction, @"What do you remember about Ollie’s Tricks?", @"incorrect introduction text");
    
    struct {
        NSString *prompt;
        NSArray *answers;
        NSInteger correctAnswer;
    } expect[] = {
        { @"Which of these tricks CAN'T Ollie do?",
            [NSArray arrayWithObjects:@"Knit socks", @"Do magic tricks", @"Drive a car", nil],
            2 },
        { @"Which of these tricks does Sam know Ollie CAN do?",
            [NSArray arrayWithObjects:@"Make cookies", @"Lie down", @"Ice Skate", nil],
            1 },
        { @"Which of these things did Ollie NOT learn from reading a book?",
            [NSArray arrayWithObjects:@"Ballroom dancing", @"Origami", @"Computers", nil],
            0 }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionMultipleChoiceQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertEqualObjects(q.answers, expect[i].answers, @"incorrect answers for question %d", i+1);
        STAssertEquals(q.correctAnswer, expect[i].correctAnswer, @"incorrect correctAnswer for question %d", i+1);
    }
}

- (void)testPopQuiz1
{
    NSArray *stories = [self parse:@"PopQuiz1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionPopQuiz class]], @"incorrect class");
    
    SCHStoryInteractionPopQuiz *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 44, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(180, 10)), @"incorrect position");
    STAssertEqualObjects(story.scoreResponseLow, @"Don’t be afraid to try again!", @"incorrect scoreResponseLow");
    STAssertEqualObjects(story.scoreResponseMedium, @"Good job! You’re no dummy!", @"incorrect scoreResponseMedium");
    STAssertEqualObjects(story.scoreResponseHigh, @"Perfect score! Spook-tacular!", @"incorrect scoreResponseHigh");
    
    struct {
        NSString *prompt;
        NSArray *answers;
        NSInteger correctAnswer;
    } expect[] = {
        { @"What did Lindy find in the dumpster?",
            [NSArray arrayWithObjects:@"A dead body", @"A runaway dog", @"A flying squirrel", @"A ventriloquist dummy", nil],
            3 },
        { @"What did Mrs. Marshall want Lindy to do?",
            [NSArray arrayWithObjects:@"Babysit her kids", @"Perform with Slappy", @"Mow the lawn", @"Deliver her newspapers", nil],
            1 },
        { @"What happened when Kris first tried to hold Slappy?",
            [NSArray arrayWithObjects:@"He gave her a high five", @"He slapped her", @"He flipped her", @"He made a face", nil],
            1 },
        { @"Who grabbed Kris after she pushed Slappy off the chair?",
            [NSArray arrayWithObjects:@"Cody", @"Slappy", @"Lindy", @"Mom", nil],
            2 },
        { @"Who gave Kris her own ventriloquist dummy?",
            [NSArray arrayWithObjects:@"Dad", @"Mom", @"Cody Matthews", @"Mrs. Marshall", nil],
            0 }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);

    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionMultipleChoiceQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertEqualObjects(q.answers, expect[i].answers, @"incorrect answers for question %d", i+1);
        STAssertEquals(q.correctAnswer, expect[i].correctAnswer, @"incorrect correctAnswer for question %d", i+1);
    }
}

- (void)testScratchAndSee1
{
    NSArray *stories = [self parse:@"ScratchAndSee1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionScratchAndSee class]], @"incorrect class");
    
    SCHStoryInteractionScratchAndSee *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 14, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(500, 5)), @"incorrect position");

    struct {
        NSArray *answers;
        NSInteger correctAnswer;
    } expect[] = {
        { [NSArray arrayWithObjects:@"Dancing", @"Eating", @"Cooking", nil], 0 },
        { [NSArray arrayWithObjects:@"Sitting", @"Skating", @"Doing yoga", nil], 2 },
        { [NSArray arrayWithObjects:@"Running", @"Shaking", @"Spinning", nil], 1 }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionScratchAndSeeQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.answers, expect[i].answers, @"incorrect answers for question %d", i+1);
        STAssertEquals(q.correctAnswer, expect[i].correctAnswer, @"incorrect correctAnswer for question %d", i+1);
        
        NSString *imagePath = [NSString stringWithFormat:@"ss1_q%d.png", i+1];
        STAssertEqualObjects([[q imagePath] lastPathComponent], imagePath, @"incorrect imagePath for question %d", i+1);
        
        NSString *correctAudioPath = [NSString stringWithFormat:@"ss1_ca%d.mp3", i+1];
        STAssertEqualObjects([[q correctAnswerAudioPath] lastPathComponent], correctAudioPath, @"incorrect correctAudioPath for question %d", i+1);
        
        for (NSInteger j = 0; j < [q.answers count]; ++j) {
            NSString *audioPath = [NSString stringWithFormat:@"ss1_q%da%d.mp3", i+1, j+1];
            STAssertEqualObjects([[q audioPathForAnswerAtIndex:j+1] lastPathComponent], audioPath, @"incorrect audioPath for question %d answer %d", i+1, j+1);
        }
    }
}

@end
