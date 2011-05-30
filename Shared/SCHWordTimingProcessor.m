//
//  SCHWordTimingProcessor.m
//  Scholastic
//
//  Created by John S. Eddie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHWordTimingProcessor.h"

#import "SCHWordTiming.h"
#import "SCHAudioBookPlayer.h"

// this is the buffer used by fgets and is more than adequate for the RXTFile
static int const kWordTimingBuffer = 1024;

static char * const kWordTimingTokenSeparator = " ";
static int const kWordTimingTimeNumberBase = 10;
static int const kWordTimingTimeTimescale = 1000;

@interface SCHWordTimingProcessor ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation SCHWordTimingProcessor

@synthesize filePath;

#pragma mark - Object lifecycle

- (id)initWithWordTimingFilePath:(NSString *)aWordTimingFilePath 
{
    self = [super init];
    if (self) {
        filePath = [aWordTimingFilePath copy];
    }
    return(self);
}

- (void)dealloc 
{
    [filePath release], filePath = nil;
    
    [super dealloc];
}

+ (NSArray *)startTimesFrom:(NSData *)wordTimingData error:(NSError **)error
{
    NSMutableArray *ret = [NSMutableArray array];
    
    if (wordTimingData == nil || [wordTimingData length] < 1) {
        if (error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to use empty data"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHAudioBookPlayerErrorDomain 
                                         code:kSCHAudioBookPlayerFileError
                                     userInfo:userInfo];
        }        
    } else {
        NSString *wordTimingString = [[NSString alloc] initWithBytesNoCopy:(void *)wordTimingData.bytes 
                                                                    length:[wordTimingData length] 
                                                                  encoding:NSASCIIStringEncoding 
                                                              freeWhenDone:NO];
        NSArray *timingLines = [wordTimingString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [wordTimingString release], wordTimingString = nil;
        
        for (NSString *currentLine in timingLines) {
            NSArray *timingElements = [currentLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([timingElements count] > 3 && [[timingElements objectAtIndex:0] integerValue] == 5) {
                SCHWordTiming *wordTiming = [[SCHWordTiming alloc] initWithStartTime:[[timingElements objectAtIndex:1] integerValue] 
                                                                             endTime:[[timingElements objectAtIndex:2] integerValue]];
                [ret addObject:wordTiming];
                [wordTiming release];
            }
        }  
    }
    
	return(ret);    
}

// TODO: add support for 05 and 5 as line delimiters
// TODO: convert results to use SCHWordTiming
// 0 location : start of the file
// 0 length : to the end of the file
- (NSArray *)startTimesWithRange:(NSRange)range error:(NSError **)error
{
    NSMutableArray *ret = [NSMutableArray array];
    FILE *file = NULL;
    char line[kWordTimingBuffer];
    NSUInteger validLineCount = 0;
    NSUInteger includedLineCount = 0;    
    char *completeLine, *startTime;
    NSMutableData *collectLine = nil;                
    NSString *tmpCompleteLine = nil;        
    size_t strLength = 0;
    long time = 0;
    
    file = fopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if (file == NULL) {
        if (error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to open file"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHAudioBookPlayerErrorDomain 
                                         code:kSCHAudioBookPlayerFileError
                                     userInfo:userInfo];
        }
    } else {
        setlinebuf(file);

        while (fgets(line, kWordTimingBuffer, file) != NULL) {
            
            if (strLength = strlen(line), strLength > 0 && line[strLength-1] == '\n') {        

                if (collectLine == nil) {
                    completeLine = line;
                } else {
                    [collectLine appendBytes:line length:strlen(line)];
                    [collectLine appendBytes:(char []){'\0'} length:1];
                    [tmpCompleteLine release];
                    tmpCompleteLine = [[NSString alloc] initWithData:collectLine encoding:NSASCIIStringEncoding];
                    completeLine = (char *)[tmpCompleteLine cStringUsingEncoding:NSASCIIStringEncoding];
                    [collectLine release], collectLine = nil;
                }

                if (strncmp(strtok(completeLine, kWordTimingTokenSeparator), "05", 2) == 0) {
                    startTime = strtok(NULL, kWordTimingTokenSeparator);                   
                    if (startTime != NULL) {
                        errno = 0;
                        time = strtol(startTime, NULL, kWordTimingTimeNumberBase);
                        if (!(time == 0 && errno == EINVAL)) {
                            if (validLineCount >= range.location) {
                                [ret addObject:[NSNumber numberWithInteger:time]];
                                includedLineCount++;
                                if (range.length > 0 && includedLineCount >= range.length) {
                                    break;
                                }
                            }
                            validLineCount++;
                        }
                    }
                }
            } else {
                if (collectLine == nil) {
                    collectLine = [[NSMutableData alloc] initWithBytes:line length:strlen(line)];
                } else {
                    [collectLine appendBytes:line length:strlen(line)];
                }
            }
        }
        [collectLine release], collectLine = nil;
        [tmpCompleteLine release], tmpCompleteLine = nil;
        
        fclose(file);
    }
        
    return(ret);
}

- (NSArray *)startTimesFromIndex:(NSUInteger)index error:(NSError **)error
{
    return([self startTimesWithRange:NSMakeRange(index, 0) error:error]);
}

- (NSArray *)startTimes:(NSError **)error
{
    return([self startTimesWithRange:NSMakeRange(0, 0) error:error]);
}

@end
