//
//  NSDate+ServerDate.m
//  Scholastic
//
//  Created by John Eddie on 30/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "NSDate+ServerDate.h"

#import "SCHAppStateManager.h"

@implementation NSDate (ServerDate)

+ (NSDate *)serverDate
{
    return [NSDate dateWithTimeIntervalSinceNow:[[SCHAppStateManager sharedAppStateManager] serverDateDelta]];
}

+ (NSDate *)serverDateWithTimeIntervalSinceNow:(NSTimeInterval)seconds
{
    return [NSDate dateWithTimeIntervalSinceNow:[[SCHAppStateManager sharedAppStateManager] serverDateDelta] + seconds];
}

@end
