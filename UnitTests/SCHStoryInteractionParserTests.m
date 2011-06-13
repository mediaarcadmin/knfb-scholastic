//
//  UnitTests.m
//  UnitTests
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionTypes.h"

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

- (void)testAboutYouQuiz1
{
    NSArray *stories = [self parse:@"AboutYouQuiz1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionAboutYouQuiz class]], @"incorrect class");

    SCHStoryInteractionAboutYouQuiz *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 162, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(180, 10)), @"incorrect position %@ should be 180,10", NSStringFromCGPoint(story.position));
    
    NSArray *expectedOutcomes = [NSArray arrayWithObjects:
                                 @"You’re a talented writer and have a knack for inventing new things.  You’re a lot like Benjamin Franklin!",
                                 @"You’re incredibly smart and love studying the sciences.  You’re a lot like Isaac Newton!",
                                 @"A natural leader, you just love being in charge. You have a lot in common with Winston Churchill!",
                                 nil];
    STAssertEqualObjects(story.outcomeMessages, expectedOutcomes, @"incorrect outcome messages");
    
    NSArray *expectedTiebreakOrder = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],[NSNumber numberWithInt:2], nil];
    
    STAssertEqualObjects(story.tiebreakOrder, expectedTiebreakOrder, @"Tiebreak order did not parse correctly");
    
    struct {
        NSString *prompt;
        NSArray *answers;
    } expect[] = {
        { @"What are you most looking forward to about college?",
            [NSArray arrayWithObjects:@"Writing for the campus newspaper", @"Performing cool experiments during physics lab", @"Becoming president of the student body", nil] },
        { @"Describe yourself in one word:",
            [NSArray arrayWithObjects:@"Creative", @"Intelligent", @"Confident", nil] },
        { @"As a child, what was your favorite way to spend a Saturday?",
            [NSArray arrayWithObjects:@"Flying my kite", @"Reading books about space", @"Playing follow the leader", nil] },
        { @"It’s time to eat! What are you craving?",
            [NSArray arrayWithObjects:@"Philly Cheese Steak", @"Apple Slices", @"French Fries", nil] },
        { @"Which of these items can be found in your locker?",
            [NSArray arrayWithObjects:@"A spare pair of eyeglasses", @"A calculator and microscope", @"A mirror and hairbrush", nil]
        }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionAboutYouQuizQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertEqualObjects(q.answers, expect[i].answers, @"incorrect answers for question %d", i+1);
    }
    
}

- (void)testHotSpot1
{
    NSArray *stories = [self parse:@"HotSpot1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionHotSpot class]], @"incorrect class");
    
    SCHStoryInteractionHotSpot *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 28, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(188, 50)), @"incorrect position %@ should be 188,50", NSStringFromCGPoint(story.position));
    
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
        
        NSString *questionAudioPath = [NSString stringWithFormat:@"ttp1_q%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForQuestion] lastPathComponent], questionAudioPath, @"incorrect question audio path for question %d", i+1);
        
        NSString *correctAnswerAudioPath = [NSString stringWithFormat:@"ttp1_ca%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForCorrectAnswer] lastPathComponent], correctAnswerAudioPath, @"incorrect correct answer audio path for question %d", i+1);
    }
}

- (void)testImage1
{
    NSArray *stories = [self parse:@"Image1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionImage class]], @"incorrect class");
    
    SCHStoryInteractionImage *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 162, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(50, 0)), @"incorrect position %@", NSStringFromCGPoint(story.position));
    
    STAssertEqualObjects(story.imageFilename, @"img1_graphic.png", @"incorrect image filename");
}

- (void)testMultipleChoiceText1
{
    NSArray *stories = [self parse:@"MultipleChoiceText1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionMultipleChoiceText class]], @"incorrect class");
    
    SCHStoryInteractionMultipleChoiceText *story = [stories lastObject];
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
        SCHStoryInteractionMultipleChoiceTextQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertEqualObjects(q.answers, expect[i].answers, @"incorrect answers for question %d", i+1);
        STAssertEquals(q.correctAnswer, expect[i].correctAnswer, @"incorrect correctAnswer for question %d", i+1);
     
        NSString *questionAudioPath = [NSString stringWithFormat:@"mc1_q%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForQuestion] lastPathComponent], questionAudioPath, @"incorrect question audio path for question %d", i+1);
        
        NSString *correctAnswerAudioPath = [NSString stringWithFormat:@"mc1_ca%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForCorrectAnswer] lastPathComponent], correctAnswerAudioPath, @"incorrect correct answer audio path for question %d", i+1);
        
        STAssertEqualObjects([[q audioPathForIncorrectAnswer] lastPathComponent], @"gen_tryagain.mp3", @"incorrect incorrect answer audio path for question %d", i+1);
        
        for (int j = 0; j < [q.answers count]; ++j) {
            NSString *answerAudioPath = [NSString stringWithFormat:@"mc1_q%da%d.mp3", i+1, j+1];
            STAssertEqualObjects([[q audioPathForAnswerAtIndex:j] lastPathComponent], answerAudioPath, @"incorrect answer %d audio path for question %d", j+1, i+1);
        }
    }
}

- (void)testMultipleChoicePictures1
{
    
    NSArray *stories = [self parse:@"MultipleChoicePicture1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionMultipleChoiceWithAnswerPictures class]], @"incorrect class");
    
    SCHStoryInteractionMultipleChoiceWithAnswerPictures *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 30, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(188, 50)), @"incorrect position");
    STAssertEqualObjects(story.introduction, @"Think about some of the words used to describe the animals in this story.", @"incorrect introduction text");
    
    struct {
        NSString *prompt;
        NSInteger numberOfAnswers;
        NSInteger correctAnswer;
    } expect[] = {
        { @"Who is SNEAKY?", 3, 1 },
        { @"Who is SILLY?", 3, 0 },
        { @"Who is SMELLY?", 3, 2 }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionMultipleChoicePictureQuestion *q = [story.questions objectAtIndex:i];
        STAssertEqualObjects(q.prompt, expect[i].prompt, @"incorrect prompt for question %d", i+1);
        STAssertEquals(q.correctAnswer, expect[i].correctAnswer, @"incorrect correctAnswer for question %d", i+1);

        NSString *questionAudioPath = [NSString stringWithFormat:@"mcp1_q%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForQuestion] lastPathComponent], questionAudioPath, @"incorrect question audio path for question %d", i+1);
        
        NSString *correctAnswerAudioPath = [NSString stringWithFormat:@"mcp1_ca%d.mp3", i+1];
        STAssertEqualObjects([[q audioPathForCorrectAnswer] lastPathComponent], correctAnswerAudioPath, @"incorrect correct answer audio path for question %d", i+1);
        
        STAssertEqualObjects([[q audioPathForIncorrectAnswer] lastPathComponent], @"gen_tryagain.mp3", @"incorrect incorrect answer audio path for question %d", i+1);
        
        for (int j = 0; j < [q.answers count]; ++j) {
            NSString *questionImagePath = [NSString stringWithFormat:@"mcp1_q%da%d.png", i+1, j+1];
            STAssertEqualObjects([[q imagePathForAnswerAtIndex:j] lastPathComponent], questionImagePath, @"incorrect answer %d image path for question %d", j+1, i+1);
                                           
            NSString *answerAudioPath = [NSString stringWithFormat:@"mc1_q%da%d.mp3", i+1, j+1];
            STAssertEqualObjects([[q audioPathForAnswerAtIndex:j] lastPathComponent], answerAudioPath, @"incorrect answer %d audio path for question %d", j+1, i+1);
        }
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
        SCHStoryInteractionMultipleChoiceTextQuestion *q = [story.questions objectAtIndex:i];
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
            STAssertEqualObjects([[q audioPathForAnswerAtIndex:j] lastPathComponent], audioPath, @"incorrect audioPath for question %d answer %d", i+1, j+1);
        }
    }
}

- (void)testSequencing1
{
    NSArray *stories = [self parse:@"Sequencing1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionSequencing class]], @"incorrect class");
    
    SCHStoryInteractionSequencing *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 34, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(188, 50)), @"incorrect position");
    
    STAssertEquals([story numberOfImages], 3, @"incorrect image count");
    for (int i = 0; i < [story numberOfImages]; ++i) {
        NSString *imageFilename = [NSString stringWithFormat:@"se1_img%d.png", i+1];
        STAssertEqualObjects([[story imagePathForIndex:i] lastPathComponent], imageFilename, @"incorrect filename for image %d", i+1);
        
        NSString *audioFilename = [NSString stringWithFormat:@"se1_ca%d.mp3", i+1];
        STAssertEqualObjects([[story audioPathForCorrectAnswerAtIndex:i] lastPathComponent], audioFilename, @"incorrect filename for audio %d", i+1);
    }
}

- (void)testStartingLetter1
{
    NSArray *stories = [self parse:@"StartingLetter1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionStartingLetter class]], @"incorrect class");
    
    SCHStoryInteractionStartingLetter *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 24, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(180, 50)), @"incorrect position");
    
    STAssertEqualObjects(story.prompt, @"Computer starts with C. Find three more things that start with the letter C.", @"incorrect prompt");
    STAssertEqualObjects(story.startingLetter, @"C", @"incorrect starting letter");
    
    struct {
        NSString *suffix;
        BOOL isCorrect;
    } expect[] = {
        { @"book", NO },
        { @"skates", NO },
        { @"television", NO },
        { @"pot", NO },
        { @"cookies", YES },
        { @"tree", NO },
        { @"bowl", NO },
        { @"cat", YES },
        { @"chicken", YES }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectCount, @"incorrect number of questions");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectCount); ++i) {
        SCHStoryInteractionStartingLetterQuestion *q = [story.questions objectAtIndex:i];
        STAssertEquals(q.isCorrect, expect[i].isCorrect, @"incorrect correct flag for question %d", i+1);
        NSString *imageFilename = [NSString stringWithFormat:@"sl1_%@.png", expect[i].suffix];
        NSString *audioFilename = [NSString stringWithFormat:@"sl1_%@.mp3", expect[i].suffix];
        STAssertEqualObjects([[q imagePath] lastPathComponent], imageFilename, @"incorrect image filename for question %d", i+1);
        STAssertEqualObjects([[q audioPath] lastPathComponent], audioFilename, @"incorrect audio filename for question %d", i+1);
    }
}

- (void)testTitleTwister1
{
    NSArray *stories = [self parse:@"TitleTwister1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionTitleTwister class]], @"incorrect class");
    
    SCHStoryInteractionTitleTwister *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 58, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(50, 10)), @"incorrect position");

    NSSet *expectWords = [NSSet setWithObjects:@"OPOSSUM", @"BEGUMS", @"BESOMS", @"BOSOMS", @"BOUSES", @"EMBOSS", @"GOBOES", @"GOMBOS", @"GOOSES", @"GUMBOS",
                            @"MOUSES", @"MOUSSE", @"OPUSES", @"OSMOSE", @"OSMOUS", @"POSSUM", @"SEBUMS", @"SPOUSE", @"SPUMES", @"UGSOME", @"BEGUM", @"BESOM", @"BOGUS",
                            @"BOOMS", @"BOSOM", @"BOUSE", @"BUMPS", @"BUSES", @"GESSO", @"GEUMS", @"GOBOS", @"GOMBO", @"GOOPS", @"GOOSE", @"GUESS", @"GUMBO", @"MEOUS",
                            @"MOOSE", @"MOPES", @"MOSSO", @"MOUES", @"MOUSE", @"MUSES", @"OBOES", @"PESOS", @"POEMS", @"POMES", @"POMOS", @"POSES", @"POSSE", @"PUBES",
                            @"PUSES", @"SEBUM", @"SEGOS", @"SMOGS", @"SOUPS", @"SOUSE", @"SPUES", @"SPUME", @"SUMOS", @"SUMPS", @"SUPES", @"UMBOS", @"BEGS", @"BOGS",
                            @"BOOM", @"BOOS", @"BOPS", @"BOSS", @"BUGS", @"BUMP", @"BUMS", @"BUSS", @"EGOS", @"EMUS", @"EPOS", @"GEMS", @"GEUM", @"GOBO", @"GOBS",
                            @"GOES", @"GOOP", @"GOOS", @"GUMS", @"MEGS", @"MEOU", @"MESS", @"MOBS", @"MOGS", @"MOOS", @"MOPE", @"MOPS", @"MOSS", @"MOUE", @"MUGS",
                            @"MUSE", @"MUSS", @"OBES", @"OBOE", @"OOPS", @"OPES", @"OPUS", @"OSES", @"PEGS", @"PESO", @"POEM", @"POME", @"POMO", @"POMS", @"POOS",
                            @"POSE", @"PUBS", @"PUGS", @"PUSS", @"SEGO", @"SEGS", @"SMOG", @"SMUG", @"SOBS", @"SOME", @"SOMS", @"SOPS", @"SOUP", @"SOUS", @"SPUE",
                            @"SUBS", @"SUES", @"SUMO", @"SUMP", @"SUMS", @"SUPE", @"SUPS", @"UMBO", @"UMPS", @"USES", @"BEG", @"BES", @"BOG", @"BOO", @"BOP", @"BOS",
                            @"BUG", @"BUM", @"BUS", @"EGO", @"EMS", @"EMU", @"ESS", @"GEM", @"GOB", @"GOO", @"GOS", @"GUM", @"MEG", @"MOB", @"MOG", @"MOO", @"MOP",
                            @"MOS", @"MUG", @"MUS", @"OBE", @"OES", @"OMS", @"OPE", @"OPS", @"OSE", @"PEG", @"PES", @"POM", @"POO", @"PUB", @"PUG", @"PUS", @"SEG",
                            @"SOB", @"SOM", @"SOP", @"SOS", @"SOU", @"SUB", @"SUE", @"SUM", @"SUP", @"UMP", @"UPO", @"UPS", @"USE", @"BE", @"BO", @"EM", @"ES", @"GO",
                            @"ME", @"MO", @"MU", @"OE", @"OM", @"OP", @"OS", @"PE", @"SO", @"UM", @"UP", @"US", nil];
    
    STAssertEqualObjects(story.bookTitle, @"GOOSEBUMPS", @"incorrect book title");
    STAssertEqualObjects(story.words, expectWords, @"incorrect word list");
}

- (void)testVideo1
{
    NSArray *stories = [self parse:@"Video1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionVideo class]], @"incorrect class");
    
    SCHStoryInteractionVideo *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 34, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(50, 20)), @"incorrect position");
    
    STAssertEqualObjects(story.videoTranscript, @"Ollie can do so many things! Let’s see some more dynamic dogs!", @"incorrect transcript");
    STAssertEqualObjects(story.videoFilename, @"vid1_1.mp4", @"incorrect video filename");
}

- (void)testWhoSaidIt1
{
    NSArray *stories = [self parse:@"WhoSaidIt1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionWhoSaidIt class]], @"incorrect class");
    
    SCHStoryInteractionWhoSaidIt *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 111, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(100, 5)), @"incorrect position");
    
    STAssertEquals(story.distracterIndex, 5, @"incorrect distracter index");
    
    struct {
        NSString *source;
        NSString *statement;
    } expect[] = {
        { @"Kris", @"I’m telling you, he’s alive!" },
        { @"Mr. Wood", @"I’m in charge now. You will listen to me. This is my house now." },
        { @"Mr. Powell", @"I really think you’ve lost your mind. I’m very worried about you." },
        { @"Lindy", @"It was just a nightmare. The horrible thing that happened at the concert – it gave you a nightmare, that’s all." },
        { @"Mrs. Berman", @"And if I have my way, you’ll be suspended for life!" },
        { @"Cody", @"" }
    };
    NSUInteger expectCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.statements count], expectCount, @"incorrect number of statements");
    for (NSUInteger i = 0; i < MIN([story.statements count], expectCount); ++i) {
        SCHStoryInteractionWhoSaidItStatement *s = [story.statements objectAtIndex:i];
        STAssertEqualObjects(s.source, expect[i].source, @"incorrect source for statement %d", i+1);
        STAssertEqualObjects(s.text, expect[i].statement, @"incorrect text for statement %d", i+1);
    }
}

- (void)testWordMatch1
{
    NSArray *stories = [self parse:@"WordMatch1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionWordMatch class]], @"incorrect class");
    
    SCHStoryInteractionWordMatch *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 8, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(450, 50)), @"incorrect position");
    
    STAssertEqualObjects(story.introduction, @"Match the the words with the pictures below.", @"incorrect introduction");

    struct item {
        NSString *text;
        NSString *suffix;
    };
    struct item q1items[] = {
        { @"Sit", @"sit" },
        { @"Eat", @"eat" },
        { @"Run", @"run" }
    };
    struct item q2items[] = {
        { @"Shake", @"shake" },
        { @"Sleep", @"sleep" },
        { @"Stand", @"stand" },
    };
    struct item q3items[] = {
        { @"Skate", @"skate" },
        { @"Type", @"type" },
        { @"Knit", @"knit" }
    };
    struct {
        struct item *items;
        NSUInteger count;
    } expect[] = {
        { q1items, sizeof(q1items)/sizeof(q1items[0]) },
        { q2items, sizeof(q2items)/sizeof(q2items[0]) },
        { q3items, sizeof(q3items)/sizeof(q3items[0]) },
    };
    NSUInteger expectQuestionCount = sizeof(expect)/sizeof(expect[0]);
    
    STAssertEquals([story.questions count], expectQuestionCount, @"incorrect question count");
    for (NSUInteger i = 0; i < MIN([story.questions count], expectQuestionCount); ++i) {
        SCHStoryInteractionWordMatchQuestion *q = [story.questions objectAtIndex:i];
        STAssertEquals([q.items count], expect[i].count, @"incorrect item count for question %d", i+1);
        
        for (NSUInteger j = 0; j < MIN([q.items count], expect[i].count); ++j) {
            SCHStoryInteractionWordMatchQuestionItem *item = [q.items objectAtIndex:j];
            STAssertEqualObjects(item.text, expect[i].items[j].text, @"incorrect text for item %d of question %d", j+1, i+1);
            
            NSString *imagePath = [NSString stringWithFormat:@"wm1_%@.png", expect[i].items[j].suffix];
            STAssertEqualObjects([[item imagePath] lastPathComponent], imagePath, @"incorrect image path for item %d of question %d", j+1, i+1);

            NSString *audioPath = [NSString stringWithFormat:@"wm1_%@.mp3", expect[i].items[j].suffix];
            STAssertEqualObjects([[item audioPath] lastPathComponent], audioPath, @"incorrect audio path for item %d of question %d", j+1, i+1);
        }  
    }
}

- (void)testWordScrambler1
{
    NSArray *stories = [self parse:@"WordScrambler1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionWordScrambler class]], @"incorrect class");
    
    SCHStoryInteractionWordScrambler *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 26, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(100, 20)), @"incorrect position");
    
    STAssertEqualObjects(story.clue, @"Lindy and I are going to perform shows at parties!", @"incorrect clue");
    STAssertEqualObjects(story.answer, @"SLAPPY", @"incorrect answer");
    
    NSArray *expectedHints = [NSArray arrayWithObjects:[NSNumber numberWithInteger:4], [NSNumber numberWithInteger:6], nil];
    STAssertEqualObjects(story.hintIndices, expectedHints, @"incorrect hint indices");
}

- (void)testWordSearch1
{
    NSArray *stories = [self parse:@"WordSearch1"];
    STAssertEquals([stories count], 1U, @"incorrect story count");
    STAssertTrue([[stories lastObject] isKindOfClass:[SCHStoryInteractionWordSearch class]], @"incorrect class");
    
    SCHStoryInteractionWordSearch *story = [stories lastObject];
    STAssertEquals(story.documentPageNumber, 20, @"incorrect documentPageNumber");
    STAssertTrue(CGPointEqualToPoint(story.position, CGPointMake(100, 20)), @"incorrect position");

    NSArray *expectWords = [NSArray arrayWithObjects:@"Pride", @"Watch", @"Sleep", @"Trick", @"Dance", @"Skate", nil];
    
    STAssertEqualObjects(story.introduction, @"Find these words from the story.", @"incorrect introduction");
    STAssertEqualObjects(story.words, expectWords, @"incorrect word list");
    STAssertEquals([story matrixRows], 6, @"incorrect row count");
    STAssertEquals([story matrixColumns], 6, @"incorrect column count");
    
    const unichar matrix[6][6] = {
        { 'D', 'P', 'R', 'I', 'D', 'E' },
        { 'S', 'E', 'Y', 'S', 'A', 'N' },
        { 'K', 'H', 'I', 'K', 'N', 'R' },
        { 'A', 'W', 'A', 'T', 'C', 'H' },
        { 'T', 'S', 'L', 'E', 'E', 'P' },
        { 'E', 'T', 'R', 'I', 'C', 'K' }
    };
    for (int row = 0; row < 6; ++row) {
        for (int col = 0; col < 6; ++col) {
            STAssertEquals([story matrixLetterAtRow:row column:col], matrix[row][col], @"incorrect letter at row %d col %d", row+1, col+1);
        }
    }
}

@end
