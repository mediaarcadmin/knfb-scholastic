//
//  NSDate+ServerDate.h
//  Scholastic
//
//  Created by John Eddie on 30/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ServerDate)

+ (NSDate *)serverDate;
+ (NSDate *)serverDateWithTimeIntervalSinceNow:(NSTimeInterval)seconds;

@end
