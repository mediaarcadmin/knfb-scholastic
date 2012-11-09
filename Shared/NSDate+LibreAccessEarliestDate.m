//
//  NSDate+LibreAccessEarliestDate.m
//  Scholastic
//
//  Created by John S. Eddie on 08/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSDate+LibreAccessEarliestDate.h"

@implementation NSDate (LibreAccessEarliestDate)

// this is the earliest date that can be accepted but the server
+ (NSDate *)SCHLibreAccessEarliestDate
{
    return [self dateWithTimeIntervalSinceReferenceDate:0.0];
}

@end
