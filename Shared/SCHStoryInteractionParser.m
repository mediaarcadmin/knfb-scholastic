//
//  SCHStoryInteractionParser.m
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionTypes.h"
#import "USAdditions.h"

// must come after USAdditions.h
#import <expat/expat.h>

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

@interface NSString (Parse)
- (void)BIT_enumerateCharactersWithBlock:(void(^)(unichar character))block;
@end

@implementation NSString (Parse)
- (void)BIT_enumerateCharactersWithBlock:(void (^)(unichar))block
{
    for (NSInteger charIndex = 0, charCount = [self length]; charIndex < charCount; ++charIndex) {
        block([self characterAtIndex:charIndex]);
    }
}
@end

static NSString *extractXmlAttribute(const XML_Char **atts, const char *key)
{
    for (int i = 0; atts[i]; i += 2) {
        if (strcmp(atts[i], key) == 0) {
            return [[NSString stringWithUTF8String:atts[i+1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        NSLog(@"page number = %d", self.documentPageNumber);
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
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        [parser.answers addObject:extractXmlAttribute(attributes, "Transcript")];
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
    } else if (strcmp(name, "Introduction") == 0) {
        self.introduction = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "OutcomeMessage") == 0) {
        NSString *outcomeMessage = extractXmlAttribute(attributes, "Transcript");
        [parser.array addObject:outcomeMessage];
    } else if (strcmp(name, "TiebreakOrder") == 0) {
        NSString *orderString = extractXmlAttribute(attributes, "Transcript");
        NSMutableArray *convertedOrder = [NSMutableArray array];
        [orderString BIT_enumerateCharactersWithBlock:^(unichar character) {
            if ('A' <= character && character <= 'Z') {
                [convertedOrder addObject:[NSNumber numberWithInt:(character-'A')]];
            }
        }];
        self.tiebreakOrder = [NSArray arrayWithArray:convertedOrder];
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

#pragma mark - Card Collection

@implementation SCHStoryInteractionCardCollectionCard (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Card") == 0) {
        self.frontFilename = extractXmlAttribute(attributes, "srcfront");
        self.backFilename = extractXmlAttribute(attributes, "srcback");
    }
}

@end

@implementation SCHStoryInteractionCardCollection (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Card") == 0) {
        [parser beginQuestion:[SCHStoryInteractionCardCollectionCard class]];
        [parser.question startElement:name attributes:attributes parser:parser];
        [parser endQuestion];
    } else if (strcmp(name, "header") == 0) {
        self.headerFilename = extractXmlAttribute(attributes, "src");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.cards = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - Concentration

@implementation SCHStoryInteractionConcentration (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = extractXmlAttribute(attributes, "Transcript");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - HotSpot

@implementation SCHStoryInteractionHotSpotQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Hotspot") == 0) {
        self.hotSpotRect = CGRectMake([extractXmlAttribute(attributes, "Left") floatValue],
                                      [extractXmlAttribute(attributes, "Top") floatValue],
                                      [extractXmlAttribute(attributes, "Width") floatValue],
                                      [extractXmlAttribute(attributes, "Height") floatValue]);
        self.originalBookSize = CGSizeMake([extractXmlAttribute(attributes, "OriginalBookWidth") floatValue],
                                           [extractXmlAttribute(attributes, "OriginalBookHeight") floatValue]);
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
        NSData *data = [NSData dataWithBase64EncodedString:parser.text];
        const uint8_t *bytes = (const uint8_t *)[data bytes];
        CGMutablePathRef path = CGPathCreateMutable();
        for (NSInteger i = 0, n = [data length]; i < n; i += 4) {
            float x = (bytes[i+0] << 8) + (bytes[i+1]);
            float y = (bytes[i+2] << 8) + (bytes[i+3]);
            if (i == 0) {
                CGPathMoveToPoint(path, NULL, x, y);
            } else {
                CGPathAddLineToPoint(path, NULL, x, y);
            }
        }
        CGPathRef pathCopy = CGPathCreateCopy(path);
        question.path = pathCopy;
        CGPathRelease(path);
        CGPathRelease(pathCopy);
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

#pragma mark - Image

@implementation SCHStoryInteractionImage (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Image") == 0) {
        self.imageFilename = extractXmlAttribute(attributes, "Url");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - MultipleChoiceText

@implementation SCHStoryInteractionMultipleChoiceTextQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        if ([[extractXmlAttribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:extractXmlAttribute(attributes, "Transcript")];
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

@implementation SCHStoryInteractionMultipleChoicePictureQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        if ([[extractXmlAttribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:[NSNull null]];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    [super parseComplete:parser];
    self.answers = nil;
}

@end

@implementation SCHStoryInteractionMultipleChoiceText (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionMultipleChoiceTextQuestion class]];
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

#pragma mark - MultipleChoicePictures

@implementation SCHStoryInteractionMultipleChoiceWithAnswerPictures (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionMultipleChoicePictureQuestion class]];
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

#pragma mark - Picture Starter

@implementation SCHStoryInteractionPictureStarterCustom (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        [parser.array addObject:extractXmlAttribute(attributes, "Transcript")];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.introductions = [NSArray arrayWithArray:parser.array];
    [super parseComplete:parser];
}

@end

#pragma mark - PopQuiz

@implementation SCHStoryInteractionPopQuizQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Answer") == 0) {
        if ([[extractXmlAttribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:extractXmlAttribute(attributes, "Transcript")];
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
        self.scoreResponseLow = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "ScoreResponseMedium") == 0) {
        self.scoreResponseMedium = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "ScoreResponseHigh") == 0) {
        self.scoreResponseHigh = extractXmlAttribute(attributes, "Transcript");
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


#pragma mark - ScratchAndSee

@implementation SCHStoryInteractionScratchAndSeeQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Answer") == 0) {
        if ([[extractXmlAttribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"]) {
            self.correctAnswer = [parser.answers count];
        }
        [parser.answers addObject:extractXmlAttribute(attributes, "Transcript")];
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

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.questions = [NSArray arrayWithArray:parser.questions];
    [super parseComplete:parser];
}

@end

#pragma mark - StartingLetter

@implementation SCHStoryInteractionStartingLetterQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Answer") == 0) {
        self.uniqueObjectName = extractXmlAttribute(attributes, "suffix");
        self.isCorrect = [[extractXmlAttribute(attributes, "IsCorrect") lowercaseString] isEqualToString:@"true"];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

@implementation SCHStoryInteractionStartingLetter (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "QuestionPrompt") == 0) {
        self.prompt = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "StartingLetter") == 0) {
        self.startingLetter = extractXmlAttribute(attributes, "Character");
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
        self.bookTitle = extractXmlAttribute(attributes, "Phrase");
    } else if (strcmp(name, "Words") == 0) {
        NSArray *words = [extractXmlAttribute(attributes, "Words") componentsSeparatedByString:@","];
        NSMutableSet *trimmedWords = [[NSMutableSet alloc] initWithCapacity:[words count]];
        NSCharacterSet *whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        for (NSString *word in words) {
            NSString *trimmedWord = [word stringByTrimmingCharactersInSet:whitespaceAndNewline];
            if ([trimmedWord length] > 0) {
                [trimmedWords addObject:[trimmedWord uppercaseString]];
            }
        }
        self.words = [NSSet setWithSet:trimmedWords];
        [trimmedWords release];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - Video

@implementation SCHStoryInteractionVideo (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Video") == 0) {
        self.videoTranscript = extractXmlAttribute(attributes, "Transcript");
        self.videoFilename = extractXmlAttribute(attributes, "Url");
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
        self.source = extractXmlAttribute(attributes, "Source");
        self.text = extractXmlAttribute(attributes, "Transcript");
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
        self.distracterIndex = [extractXmlAttribute(attributes, "Index") integerValue] - 1;
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

#pragma mark - Word Bird

@implementation SCHStoryInteractionWordBirdQuestion (Parser)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Problem") == 0) {
        self.word = extractXmlAttribute(attributes, "Transcript");
        self.suffix = extractXmlAttribute(attributes, "suffix");
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

@implementation SCHStoryInteractionWordBird (Parser)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Problem") == 0) {
        [parser beginQuestion:[SCHStoryInteractionWordBirdQuestion class]];
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

#pragma mark - Word Match

@implementation SCHStoryInteractionWordMatchQuestion (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Statement") == 0) {
        SCHStoryInteractionWordMatchQuestionItem *item = [[SCHStoryInteractionWordMatchQuestionItem alloc] init];
        item.storyInteraction = parser.story;
        item.text = extractXmlAttribute(attributes, "Transcript");
        item.uniqueObjectName = extractXmlAttribute(attributes, "suffix");
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
        self.introduction = extractXmlAttribute(attributes, "Transcript");
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

#pragma mark - Word Scrambler

@implementation SCHStoryInteractionWordScrambler (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Scramble") == 0) {
        self.clue = extractXmlAttribute(attributes, "Clue");
        self.answer = extractXmlAttribute(attributes, "Answer");
    } else if (strcmp(name, "Hint") == 0) {
        NSArray *hints = [extractXmlAttribute(attributes, "index") componentsSeparatedByString:@","];
        NSMutableArray *hintNumbers = [[NSMutableArray alloc] initWithCapacity:[hints count]];
        for (NSString *hint in hints) {
            [hintNumbers addObject:[NSNumber numberWithInteger:[hint integerValue]]];
        }
        self.hintIndices = [NSArray arrayWithArray:hintNumbers];
        [hintNumbers release];
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

@end

#pragma mark - Word Search

@implementation SCHStoryInteractionWordSearch (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = extractXmlAttribute(attributes, "Transcript");
    } else if (strcmp(name, "Word") == 0) {
        if (!parser.answers) {
            parser.answers = [NSMutableArray array];
        }
        [parser.answers addObject:extractXmlAttribute(attributes, "Transcript")];
    } else if (strcmp(name, "Row") == 0) {
        NSString *row = extractXmlAttribute(attributes, "Letters");
        BOOL isFirstRow = ([parser.array count] == 0);
        __block NSInteger letterCount = 0;
        // string is ostensibly comma-separated but bad forms exist so just extract
        // the meaningful characters
        [row BIT_enumerateCharactersWithBlock:^(unichar character) {
            if ('A' <= character && character <= 'Z') {
                NSString *letterString = [NSString stringWithCharacters:&character length:1];
                [parser.array addObject:letterString];
                letterCount++;
            }
        }];
        if (isFirstRow) {
            self.matrixColumns = letterCount;
        } else {
            if (letterCount != self.matrixColumns) {
                NSLog(@"expected %d letters in WordSearch rows '%@'", self.matrixColumns, row);
            }
        }
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)parseComplete:(SCHStoryInteractionParser *)parser
{
    self.words = [NSArray arrayWithArray:parser.answers];

    NSMutableString *matrix = [[NSMutableString alloc] init];
    for (NSString *str in parser.array) {
        [matrix appendString:str];
    }
    self.matrix = [NSString stringWithString:matrix];
    [matrix release];
    
    [super parseComplete:parser];
}

@end

#pragma mark - Parser

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
        NSString *type = extractXmlAttribute(attributes, "StoryInteractionType");
        if (type) {
            Class storyInteractionClass = NSClassFromString([@"SCHStoryInteraction" stringByAppendingString:type]);
            if (storyInteractionClass) {
                self.story = [[[storyInteractionClass alloc] init] autorelease];
            }
        }
        if (self.story) {
            self.story.ID = extractXmlAttribute(attributes, "ID");
            self.questions = [NSMutableArray array];
            self.array = [NSMutableArray array];
            NSLog(@"found %s ID=%@", object_getClassName(self.story), self.story.ID);
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
