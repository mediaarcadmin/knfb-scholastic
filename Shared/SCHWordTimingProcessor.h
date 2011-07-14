//
//  SCHWordTimingProcessor.h
//  Scholastic
//
//  Created by John S. Eddie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHWordTimingProcessor : NSObject 
{
}

@property (nonatomic, assign) BOOL newRTXFormat;

- (NSArray *)startTimesFrom:(NSData *)wordTimingData error:(NSError **)error;

@end
