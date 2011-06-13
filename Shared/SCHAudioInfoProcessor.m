//
//  SCHAudioInfoProcessor.m
//  Scholastic
//
//  Created by John S. Eddie on 27/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioInfoProcessor.h"

#import "SCHAudioBookPlayer.h"
#import "SCHAudioInfo.h"

@interface SCHAudioInfoProcessor ()

@property (nonatomic, retain) NSMutableArray *audioInfo;
@property (nonatomic, assign) NSUInteger lastPageIndex;
@property (nonatomic, assign) NSUInteger lastTimeIndex;
@property (nonatomic, assign) NSUInteger lastTimeOffset;
@property (nonatomic, assign) NSUInteger lastAudioRefIndex;


@end

@implementation SCHAudioInfoProcessor

@synthesize audioInfo;
@synthesize lastPageIndex;
@synthesize lastTimeIndex;
@synthesize lastTimeOffset;
@synthesize lastAudioRefIndex;

#pragma mark - Object lifecycle

- (NSArray *)audioInfoFrom:(NSData *)audioData error:(NSError **)error
{    
    if (audioData == nil || [audioData length] < 1) {
        if (error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to use empty data"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHAudioBookPlayerErrorDomain 
                                         code:kSCHAudioBookPlayerFileError
                                     userInfo:userInfo];
        }        
    } else {
        self.audioInfo = [NSMutableArray array];
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:audioData];
        xmlParser.delegate = self;
        if ([xmlParser parse] == NO) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to parse Audio.xml"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHAudioBookPlayerErrorDomain 
                                         code:kSCHAudioBookPlayerFileError
                                     userInfo:userInfo];
        }
        [xmlParser release], xmlParser = nil; 
    }
        
    return(self.audioInfo);
}

- (void)dealloc 
{
    [audioInfo release], audioInfo = nil;
    [super dealloc];
}

#pragma mark - XML Parser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict 
{    
	if ([elementName isEqualToString:@"Page"]) {
        self.lastPageIndex = [[attributeDict objectForKey:@"PageIndex"] integerValue];
        self.lastTimeIndex = NSUIntegerMax;
        self.lastTimeOffset = NSUIntegerMax;
        self.lastAudioRefIndex = NSUIntegerMax;
	} else if ([elementName isEqualToString:@"AudioSegment"]) {
        self.lastTimeIndex = [[attributeDict objectForKey:@"TimeIndex"] integerValue];
        self.lastTimeOffset = [[attributeDict objectForKey:@"TimeOffset"] integerValue];
	} else if ([elementName isEqualToString:@"AudioRef"]) {
        self.lastAudioRefIndex = [[attributeDict objectForKey:@"AudioRefIndex"] integerValue];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
{
	if ([elementName isEqualToString:@"Page"]) {
        if (self.lastPageIndex != NSUIntegerMax &&
            self.lastTimeIndex != NSUIntegerMax &&
            self.lastTimeOffset != NSUIntegerMax &&
            self.lastAudioRefIndex != NSUIntegerMax) {
            SCHAudioInfo *newAudioInfo = [[SCHAudioInfo alloc]  initWithPageIndex:self.lastPageIndex 
                                                                        timeIndex:self.lastTimeIndex 
                                                                       timeOffset:self.lastTimeOffset 
                                                              audioReferenceIndex:self.lastAudioRefIndex];
            [self.audioInfo addObject:newAudioInfo];
            [newAudioInfo release], newAudioInfo = nil;
        } else {
            [parser abortParsing];
        }
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.audioInfo = nil;
}

@end
