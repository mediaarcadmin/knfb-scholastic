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
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];

    return [NSDate dateWithTimeIntervalSinceNow:[appStateManager.appState.ServerDateDelta doubleValue]];
}

+ (NSDate *)serverDateWithTimeIntervalSinceNow:(NSTimeInterval)seconds
{
    SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
    
    return [NSDate dateWithTimeIntervalSinceNow:[appStateManager.appState.ServerDateDelta doubleValue] + seconds];
}

@end
