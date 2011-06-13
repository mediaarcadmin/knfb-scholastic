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


@implementation SCHWordTimingProcessor

#pragma mark - Object lifecycle

- (NSArray *)startTimesFrom:(NSData *)wordTimingData error:(NSError **)error
{
    NSMutableArray *ret = [NSMutableArray array];
    
    if (wordTimingData == nil || [wordTimingData length] < 1) {
        if (error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to use empty data"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHAudioBookPlayerErrorDomain 
                                         code:kSCHAudioBookPlayerFileError
                                     userInfo:userInfo];
            ret = nil;
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

@end
