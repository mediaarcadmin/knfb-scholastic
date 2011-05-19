//
//  SCHWordTiming.h
//  Scholastic
//
//  Created by John S. Eddie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHWordTiming : NSObject 
{
}

- (id)initWithWordTimingFilePath:(NSString *)aWordTimingFilePath;
- (NSArray *)startTimesWithRange:(NSRange)range error:(NSError **)error;
- (NSArray *)startTimesFromIndex:(NSUInteger)index error:(NSError **)error;
- (NSArray *)startTimes:(NSError **)error;

@end
