//
//  SCHStoryInteractionParser.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <expat/expat.h>

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionAboutYouQuiz.h"
#import "SCHStoryInteractionHotSpot.h"
#import "SCHStoryInteractionMultipleChoice.h"
#import "SCHStoryInteractionPopQuiz.h"
#import "SCHStoryInteractionScratchAndSee.h"
#import "SCHStoryInteractionStartingLetter.h"
#import "SCHStoryInteractionTitleTwister.h"
#import "SCHStoryInteractionWhoSaidIt.h"
#import "SCHStoryInteractionWordMatch.h"
#import "SCHStoryInteractionWordScrambler.h"
#import "SCHStoryInteractionWordSearch.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"

// Parsing Interactions.xml is complex, with many different class types. The parser is kept
// clean and extensible by defining parsing categories on the model objects involved and
// handing off parsing logic to these objects polymorphically as the parse state progresses.

#pragma mark - SCHStoryInteractionParser private interface

@interface SCHStoryInteractionParser ()

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) SCHStoryInteraction *story;
@property (nonatomic, retain) SCHStoryInteractionQuestion *question;
@property (nonatomic, retain) NSMutableString *text;
@property (nonatomic, retain) NSMutableArray *questions;
@property (nonatomic, retain) NSMutableArray *answers;
@property (nonatomic, retain) NSMutableArray *array; // general purpose per-story

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes;
- (void)endElement:(const XML_Char *)name;
- (void)beginQuestion:(Class)questionClass;
- (void)endQuestion;

@end

#pragma mark - Parsing categories

@interface SCHStoryInteractionQuestion (Parse)
- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser;
- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser;
- (void)parseComplete:(SCHStoryInteractionParser *)parser;
@end

@interface SCHStoryInteraction (Parse)
- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser;
- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser;
- (void)parseComplete:(SCHStoryInteractionParser *)parser;
@end

static NSString *attribute(const XML_Char **atts, const char *key)
{
    for (int i = 0; atts[i]; i += 2) {
        if (strcmp(atts[i], key) == 0) {
            return [[NSString stringWithUTF8String:atts[i+1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
    return nil;
}

#pragma mark - Default implementations

// Where these are overridden, ensure to call the super version to avoid breaking the parser
// should anything be added to these in the future.

@implementation SCHStoryInteractionQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{}

@end

@implementation SCHStoryInteraction (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "DocumentPageNumber") == 0) {
        self.documentPageNumber = [parser.text integerValue];
    }
    else if (strcmp(name, "Position") == 0) {
        NSArray *parts = [parser.text componentsSeparatedByString:@","];
        if ([parts count] == 2) {
            float x = [[parts objectAtIndex:0] floatValue];
            float y = [[parts objectAtIndex:1] floatValue];
            self.position = CGPointMake(x, y);
        }
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{}

@end

#pragma mark - AboutYouQuiz

@implementation SCHStoryInteractionAboutYouQuizQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        [parser.answers addObject:attribute(attributes, "Transcript")];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question") == 0) {
        [parser endQuestion];
    } else {
        [super endElement:name parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.answers = [NSArray arrayWithArray:parser.answers];
    [super parseComplete:parser];
}

@end

@implementation SCHStoryInteractionAboutYouQuiz (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question") == 0) {
        [parser beginQuestion:[SCHStoryInteractionAboutYouQuizQuestion class]];
    } else if (strcmp(name, "OutcomeMessage") == 0) {
        NSString *outcomeMessage = attribute(attributes, "Transcript");
        [parser.array addObject:outcomeMessage];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    self.outcomeMessages = [NSArray arrayWithArray:parser.array];
    [super parseComplete:parser];
}

@end

#pragma mark - HotSpot

@implementation SCHStoryInteractionHotSpotQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Hotspot") == 0) {
        self.hotSpotRect = CGRectMake([attribute(attributes, "Left") floatValue],
                                      [attribute(attributes, "Top") floatValue],
                                      [attribute(attributes, "Width") floatValue],
                                      [attribute(attributes, "Height") floatValue]);
        self.originalBookSize = CGSizeMake([attribute(attributes, "OriginalBookWidth") floatValue],
                                           [attribute(attributes, "OriginalBookHeight") floatValue]);
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser endQuestion];
    } else if (strcmp(name, "Data") == 0) {
        SCHStoryInteractionHotSpotQuestion *question = (SCHStoryInteractionHotSpotQuestion *)parser.question;
        question.data = nil; // TODO: decode data string
    } else {
        [super endElement:name parser:parser];
    }
}

@end

@implementation SCHStoryInteractionHotSpot (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionHotSpotQuestion class]];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - MultipleChoice

@implementation SCHStoryInteractionMultipleChoiceQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        if ([[attribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:attribute(attributes, "Transcript")];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser endQuestion];
    } else {
        [super endElement:name parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.answers = [NSArray arrayWithArray:parser.answers];
    [super parseComplete:parser];
}

@end

@implementation SCHStoryInteractionMultipleChoice (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionMultipleChoiceQuestion class]];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - PopQuiz

@implementation SCHStoryInteractionPopQuizQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        if ([[attribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:attribute(attributes, "Transcript")];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question") == 0) {
        [parser endQuestion];
    } else {
        [super endElement:name parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.answers = [NSArray arrayWithArray:parser.answers];
    [super parseComplete:parser];
}


@end

@implementation SCHStoryInteractionPopQuiz (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name,"Question") == 0) {
        [parser beginQuestion:[SCHStoryInteractionPopQuizQuestion class]];
    } else if (strcmp(name, "ScoreResponseLow") == 0) {
        self.scoreResponseLow = attribute(attributes, "Transcript");
    } else if (strcmp(name, "ScoreResponseMedium") == 0) {
        self.scoreResponseMedium = attribute(attributes, "Transcript");
    } else if (strcmp(name, "ScoreResponseHigh") == 0) {
        self.scoreResponseHigh = attribute(attributes, "Transcript");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end


#pragma mark - ScratchAndSee

@implementation SCHStoryInteractionScratchAndSeeQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Answer") == 0) {
        if ([[attribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:attribute(attributes, "Transcript")];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question") == 0) {
        [parser endQuestion];
    } else {
        [super endElement:name parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.answers = [NSArray arrayWithArray:parser.answers];
    [super parseComplete:parser];
}

@end

@implementation SCHStoryInteractionScratchAndSee (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question") == 0) {
        [parser beginQuestion:[SCHStoryInteractionScratchAndSeeQuestion class]];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - StartingLetter

@implementation SCHStoryInteractionStartingLetterQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Answer") == 0) {
        self.uniqueObjectName = attribute(attributes, "suffix");
        self.isCorrect = [[attribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

@implementation SCHStoryInteractionStartingLetter (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = attribute(attributes, "Transcript");
    } else if (strcmp(name, "StartingLetter") == 0) {
        self.startingLetter = attribute(attributes, "Character");
    } else if (strcmp(name, "Answer") == 0) {
        [parser beginQuestion:[SCHStoryInteractionStartingLetterQuestion class]];
        [parser.question startElement:name attributes:attributes parser:parser];
        [parser endQuestion];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - TitleTwister

@implementation SCHStoryInteractionTitleTwister (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "BookTitle") == 0) {
        self.bookTitle = attribute(attributes, "Phrase");
    } else if (strcmp(name, "Words") == 0) {
        NSArray *words = [attribute(attributes, "Words") componentsSeparatedByString:@","];
        NSMutableArray *trimmedWords = [NSMutableArray arrayWithCapacity:[words count]];
        NSCharacterSet *whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        for (NSString *word in words) {
            NSString *trimmedWord = [word stringByTrimmingCharactersInSet:whitespaceAndNewline];
            if ([trimmedWord length] > 0) {
                [trimmedWords addObject:trimmedWord];
            }
        }
        self.words = [NSArray arrayWithArray:trimmedWords];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - WhoSaidIt

@implementation SCHStoryInteractionWhoSaidItStatement (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Statement") == 0) {
        self.source = attribute(attributes, "Source");
        self.text = attribute(attributes, "Transcript");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

@implementation SCHStoryInteractionWhoSaidIt (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Distracter") == 0) {
        // translate to 0-based index
        self.distracterIndex = [attribute(attributes, "Index") integerValue] - 1;
    } else if (strcmp(name, "Statement") == 0) {
        [parser beginQuestion:[SCHStoryInteractionWhoSaidItStatement class]];
        [parser.question startElement:name attributes:attributes parser:parser];
        [parser endQuestion];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.statements = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - WordMatch

@implementation SCHStoryInteractionWordMatchQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Statement") == 0) {
        SCHStoryInteractionWordMatchQuestionItem *item = [[SCHStoryInteractionWordMatchQuestionItem alloc] init];
        item.storyInteraction = parser.story;
        item.text = attribute(attributes, "Transcript");
        item.uniqueObjectName = attribute(attributes, "suffix");
        [parser.answers addObject:item];
        [item release];
    }
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser endQuestion];
    } else {
        [super endElement:name parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.items = [NSArray arrayWithArray:parser.answers];
    [super parseComplete:parser];
}

@end

@implementation SCHStoryInteractionWordMatch (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = attribute(attributes, "Transcript");
    } else if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionWordMatchQuestion class]];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark -

@implementation SCHStoryInteractionWordScrambler (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionWordSearch (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name parser:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionParser

@synthesize stories;
@synthesize story;
@synthesize question;
@synthesize text;
@synthesize questions;
@synthesize answers;
@synthesize  array;

- (void)dealloc
{
    [stories release];
    [story release];
    [question release];
    [text release];
    [questions release];
    [answers release];
    [array release];
    [super dealloc];
}

static void storyInteractionStartElementHandler(void *userData, const XML_Char *name, const XML_Char **atts)
{
    SCHStoryInteractionParser *parser = (SCHStoryInteractionParser *)userData;
    [parser startElement:name attributes:atts];
}

static void storyInteractionEndElementHandler(void *userData, const XML_Char *name)
{
    SCHStoryInteractionParser *parser = (SCHStoryInteractionParser *)userData;
    [parser endElement:name];
}

static void storyInteractionCharacterDataHandler(void *userData, const XML_Char *chars, int len)
{    
    char *nulterminated = malloc(len+1);
    strncpy(nulterminated, chars, len);
    nulterminated[len] = '\0';

    SCHStoryInteractionParser *parser = (SCHStoryInteractionParser *)userData;
    [parser.text appendString:[NSString stringWithUTF8String:nulterminated]];
    
    free(nulterminated);
}

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes
{
    self.text = [NSMutableString string];
    if (self.question != nil) {
        [self.question startElement:name attributes:attributes parser:self];
    } else if (self.story != nil) {
        [self.story startElement:name attributes:attributes parser:self];
    } else if (strcmp(name, "StoryInteraction") == 0) {
        NSString *type = attribute(attributes, "StoryInteractionType");
        if (type) {
            Class storyInteractionClass = NSClassFromString([@"SCHStoryInteraction" stringByAppendingString:type]);
            if (storyInteractionClass) {
                self.story = [[[storyInteractionClass alloc] init] autorelease];
            }
        }
        if (self.story) {
            self.story.ID = attribute(attributes, "ID");
            self.questions = [NSMutableArray array];
            self.array = [NSMutableArray array];
        } else {
            NSLog(@"unknown StoryInteractionType: %@", type);
        }
    }
}

- (void)endElement:(const XML_Char *)name
{
    if (self.question != nil) {
        [self.question endElement:name parser:self];
    } else if (self.story != nil) {
        if (strcmp(name, "StoryInteraction") == 0) {
            [self.story parseComplete:self];
            [self.stories addObject:self.story];
            self.story = nil;
            self.questions = nil;
            self.array = nil;
        } else { 
            [self.story endElement:name parser:self];
        }
    }
    self.text = nil;
}

- (void)beginQuestion:(Class)questionClass
{
    self.question = [[[questionClass alloc] init] autorelease];
    self.question.storyInteraction = self.story;
    self.question.questionIndex = [self.questions count];
    self.answers = [NSMutableArray array];
}

- (void)endQuestion
{
    [self.question parseComplete:self];
    [self.questions addObject:self.question];
    self.question = nil;
    self.answers = nil;
}

- (NSArray *)parseStoryInteractionsFromXPSProvider:(SCHXPSProvider *)xpsProvider
{
    NSData *xml = [xpsProvider dataForComponentAtPath:KNFBXPSStoryInteractionsMetadataFile];
    return [self parseStoryInteractionsFromData:xml];
}

- (NSArray *)parseStoryInteractionsFromData:(NSData *)xml
{
    self.stories = [NSMutableArray array];
    
    XML_Parser xmlParser = XML_ParserCreate("UTF-8");
    XML_SetElementHandler(xmlParser, storyInteractionStartElementHandler, storyInteractionEndElementHandler);
    XML_SetCharacterDataHandler(xmlParser, storyInteractionCharacterDataHandler);
    XML_SetUserData(xmlParser, (void *)self);    
    XML_Parse(xmlParser, [xml bytes], [xml length], XML_TRUE);
    XML_ParserFree(xmlParser);
    
    return self.stories;
}

@end
