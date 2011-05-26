//
//  SCHWordTimingProcessor.h
//  Scholastic
//
//  Created by John S. Eddie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kSCHAudioBookPlayerErrorDomain = @"AudioBookPlayerErrorDomain";
static NSInteger const kSCHAudioBookPlayerFileError = 2000;
static NSInteger const kSCHAudioBookPlayerDataError = 2001;

@interface SCHWordTimingProcessor : NSObject 
{
}

- (id)initWithWordTimingFilePath:(NSString *)aWordTimingFilePath;
+ (NSArray *)startTimesFrom:(NSData *)wordTimingData error:(NSError **)error;
- (NSArray *)startTimesWithRange:(NSRange)range error:(NSError **)error;
- (NSArray *)startTimesFromIndex:(NSUInteger)index error:(NSError **)error;
- (NSArray *)startTimes:(NSError **)error;

@end
