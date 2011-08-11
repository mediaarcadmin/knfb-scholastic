//
//  SCHStoryInteractionJigsawPaths.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPaths.h"

#import <expat/expat.h>

@interface SCHStoryInteractionJigsawPaths ()

@property (nonatomic, assign) CGSize scale;
@property (nonatomic, retain) NSMutableArray *paths;
@property (nonatomic, assign) NSInteger canvasDepth;

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes;
- (void)endElement:(const XML_Char *)name;
- (CGPathRef)parseXamlPath:(NSString *)pathString;
- (CGPoint)parsePoint:(NSString *)pointString;

@end

@implementation SCHStoryInteractionJigsawPaths

@synthesize paths;
@synthesize scale;
@synthesize canvasDepth;

- (void)dealloc
{
    [paths release], paths = nil;
    [super dealloc];
}

static void jigsawStartElementHandler(void *userData, const XML_Char *name, const XML_Char **atts)
{
    SCHStoryInteractionJigsawPaths *parser = (SCHStoryInteractionJigsawPaths *)userData;
    [parser startElement:name attributes:atts];
}

static void jigsawEndElementHandler(void *userData, const XML_Char *name)
{
    SCHStoryInteractionJigsawPaths *parser = (SCHStoryInteractionJigsawPaths *)userData;
    [parser endElement:name];
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.canvasDepth = 0;
        self.paths = [NSMutableArray array];
        
        XML_Parser xmlParser = XML_ParserCreate("UTF-8");
        XML_SetElementHandler(xmlParser, jigsawStartElementHandler, jigsawEndElementHandler);
        XML_SetUserData(xmlParser, (void *)self);    
        XML_Parse(xmlParser, [data bytes], [data length], XML_TRUE);
        XML_ParserFree(xmlParser);
    }
    
    return self;
}

#pragma mark - accessors

- (NSInteger)numberOfPaths
{
    return [self.paths count];
}

- (CGPathRef)pathAtIndex:(NSInteger)pathIndex
{
    return (CGPathRef)[self.paths objectAtIndex:pathIndex];
}

#pragma mark - parsing

- (void)startElement:(const XML_Char *)name attributes:(const XML_Char **)attributes
{
    if (strcasecmp(name, "canvas") == 0) {
        if (self.canvasDepth == 0) {
            CGFloat width = 0, height = 0;
            for (int i = 0; attributes[i] != NULL; i += 2) {
                if (strcasecmp(attributes[i], "width") == 0) {
                    width = atof(attributes[i+1]);
                } else if (strcasecmp(attributes[i], "height") == 0) {
                    height = atof(attributes[i+1]);
                }
            }
            self.scale = CGSizeMake(1.0f/width, 1.0f/height);
        }
        self.canvasDepth++;
    }
    else if (self.canvasDepth > 0 && strcasecmp(name, "path") == 0) {
        for (int i = 0; attributes[i] != NULL; i += 2) {
            if (strcasecmp(attributes[i], "data") == 0) {
                NSString *data = [[NSString stringWithUTF8String:attributes[i+1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                CGPathRef path = [self parseXamlPath:data];
                [self.paths addObject:(id)path];
                CGPathRelease(path);
            }
        }
    }
}

- (void)endElement:(const XML_Char *)name
{
    if (strcasecmp(name, "canvas") == 0) {
        self.canvasDepth--;
    }
}

- (CGPathRef)parseXamlPath:(NSString *)pathString
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSArray *words = [pathString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger wordIndex = 0, wordCount = [words count];
    while (wordIndex < wordCount) {
        NSString *word = [words objectAtIndex:wordIndex];
        if ([word isEqualToString:@"M"] && wordIndex+1 < wordCount) {
            CGPoint point = [self parsePoint:[words objectAtIndex:wordIndex+1]];
            CGPathMoveToPoint(path, NULL, point.x, point.y);
            wordIndex += 2;
        }
        else if ([word isEqualToString:@"L"] && wordIndex+1 < wordCount) {
            CGPoint point = [self parsePoint:[words objectAtIndex:wordIndex+1]];
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
            wordIndex += 2;
        }
        else if ([word isEqualToString:@"C"] && wordIndex+3 < wordCount) {
            CGPoint control1 = [self parsePoint:[words objectAtIndex:wordIndex+1]];
            CGPoint control2 = [self parsePoint:[words objectAtIndex:wordIndex+2]];
            CGPoint endPoint = [self parsePoint:[words objectAtIndex:wordIndex+3]];
            CGPathAddCurveToPoint(path, NULL, control1.x, control1.y, control2.x, control2.y, endPoint.x, endPoint.y);
            wordIndex += 4;
        }
        else if ([word isEqualToString:@"Z"]) {
            CGPathCloseSubpath(path);
            wordIndex += 1;
        }
        else {
            NSLog(@"unknown XAML Path command: %@", word);
            wordIndex++;
        }
    }
    
    CGPathRef immutablePath = CGPathCreateCopy(path);
    CGPathRelease(path);
    return immutablePath;
}

- (CGPoint)parsePoint:(NSString *)pointString
{
    NSRange comma = [pointString rangeOfString:@","];
    if (comma.location == NSNotFound) {
        return CGPointZero;
    } else {
        CGFloat x = [[pointString substringToIndex:comma.location] floatValue];
        CGFloat y = [[pointString substringFromIndex:comma.location+comma.length] floatValue];
        return CGPointMake(x * self.scale.width, y * self.scale.height);
    }
}

@end
