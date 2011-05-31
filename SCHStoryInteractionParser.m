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

#pragma mark - SCHStoryInteractionParser private interface

@interface SCHStoryInteractionParser ()

@property (nonatomic, retain) NSMutableArray *stories;
@property (nonatomic, retain) NSString *storyID;
@property (nonatomic, retain) SCHStoryInteraction *story;
@property (nonatomic, retain) NSMutableString *text;
@property (nonatomic, retain) NSMutableArray *questions;
@property (nonatomic, retain) NSMutableArray *answers;
@property (nonatomic, retain) NSObject *question;

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes;
- (void)endElement:(const XML_Char *)name;
- (void)beginQuestion:(Class)questionClass;
- (void)endQuestion;

@end

#pragma mark -

@interface SCHStoryInteraction (Parse)
- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser;
- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser;
@end

static NSString *attribute(const XML_Char **atts, const char *key)
{
    for (int i = 0; atts[i]; i += 2) {
        if (strcmp(atts[i], key) == 0) {
            return [NSString stringWithUTF8String:atts[i+1]];
        }
    }
    return nil;
}

#pragma mark -

@implementation SCHStoryInteraction (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "DocumentPageNumber") == 0) {
        self.documentPageNumber = [text integerValue];
    }
    else if (strcmp(name, "Position") == 0) {
        NSArray *parts = [text componentsSeparatedByString:@","];
        if ([parts count] == 2) {
            float x = [[parts objectAtIndex:0] floatValue];
            float y = [[parts objectAtIndex:1] floatValue];
            self.position = CGPointMake(x, y);
        }
    }
}

@end

#pragma mark -

@implementation SCHStoryInteractionHotSpot (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionHotSpotQuestion class]];
    }
    else if (parser.question) {
        SCHStoryInteractionHotSpotQuestion *question = (SCHStoryInteractionHotSpotQuestion *)parser.question;
        if (strcmp(name, "QuestionPrompt") == 0) {
            question.prompt = attribute(attributes, "Transcript");
        }
        else if (strcmp(name, "Hotspot") == 0) {
            question.hotSpotRect = CGRectMake([attribute(attributes, "Left") floatValue],
                                              [attribute(attributes, "Top") floatValue],
                                              [attribute(attributes, "Width") floatValue],
                                              [attribute(attributes, "Height") floatValue]);
            question.originalBookSize = CGSizeMake([attribute(attributes, "OriginalBookWidth") floatValue],
                                                   [attribute(attributes, "OriginalBookHeight") floatValue]);
        }
    } else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    if (parser.question) {
        if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
            [parser endQuestion];
        }
        else if (strcmp(name, "Data") == 0) {
            SCHStoryInteractionHotSpotQuestion *question = (SCHStoryInteractionHotSpotQuestion *)parser.question;
            question.data = nil; // TODO: decode data string
        }
    } else {
        [super endElement:name text:text parser:parser];
    }
}

@end

#pragma mark -

@implementation SCHStoryInteractionMultipleChoice (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Introduction") == 0) {
        self.introduction = attribute(attributes, "Transcript");
    }
    else if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser beginQuestion:[SCHStoryInteractionMultipleChoiceQuestion class]];
    }
    else if (parser.question) {
        SCHStoryInteractionMultipleChoiceQuestion *question = (SCHStoryInteractionMultipleChoiceQuestion *)parser.question;
        if (strcmp(name, "QuestionPrompt") == 0) {
            question.prompt = attribute(attributes, "Transcript");
        }
        else if (strcmp(name, "Answer") == 0) {
            if ([attribute(attributes, "IsCorrect") isEqualToString:@"true"]) {
                question.correctAnswer = [parser.answers count];
            }
            [parser.answers addObject:attribute(attributes, "Transcript")];
        }
    }
    else {
        [super startElement:name attributes:attributes parser:parser];
    }
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    if (strcmp(name, "Question1") == 0 || strcmp(name, "Question2") == 0 || strcmp(name, "Question3") == 0) {
        [parser endQuestion];
    }
    else {
        [super endElement:name text:text parser:parser];
    }
}

@end

#pragma mark -

@implementation SCHStoryInteractionPopQuiz (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end


#pragma mark -

@implementation SCHStoryInteractionScratchAndSee (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionStartingLetter (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionTitleTwister (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionWhoSaidIt (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionWordMatch (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionWordScrambler (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionWordSearch (Parse)

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)endElement:(const XML_Char *)name text:(NSString *)text parser:(SCHStoryInteractionParser *)parser
{
    
}

- (void)objectComplete:(SCHStoryInteractionParser *)parser
{
    
}

@end

#pragma mark -

@implementation SCHStoryInteractionParser

@synthesize stories;
@synthesize story;
@synthesize storyID;
@synthesize text;
@synthesize questions;
@synthesize answers;
@synthesize question;

- (void)dealloc
{
    [stories release];
    [story release];
    [storyID release];
    [text release];
    [questions release];
    [question release];
    [answers release];
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
    if (strcmp(name, "StoryInteraction") == 0) {
        NSString *type = attribute(attributes, "StoryInteractionType");
        if (type) {
            Class storyInteractionClass = NSClassFromString([@"SCHStoryInteraction" stringByAppendingString:type]);
            if (storyInteractionClass) {
                self.story = [[[storyInteractionClass alloc] init] autorelease];
            }
        }
        if (!self.story) {
            NSLog(@"unknown StoryInteractionType: %@", type);
        } else {
            self.storyID = attribute(attributes, "ID");
            self.questions = [NSMutableArray array];
        }
    } else if (self.story != nil) {
        self.text = [NSMutableString string];
        [self.story startElement:name attributes:attributes parser:self];
    }
}

- (void)endElement:(const XML_Char *)name
{
    if (strcmp(name, "StoryInteraction") == 0) {
        if ([self.story respondsToSelector:@selector(setQuestions:)]) {
            [(id)self.story setQuestions:self.questions];
        }
        [self.stories addObject:self.story];
        self.story = nil;
        self.storyID = nil;
    } else {
        [self.story endElement:name text:self.text parser:self];
        self.text = nil;
    }
}

- (void)beginQuestion:(Class)questionClass
{
    self.question = [[[questionClass alloc] init] autorelease];
    self.answers = [NSMutableArray array];
}

- (void)endQuestion
{
    if ([self.question respondsToSelector:@selector(setAnswers:)]) {
        [(id)self.question setAnswers:self.answers];
    }
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
