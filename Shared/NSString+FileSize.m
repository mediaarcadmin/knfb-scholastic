//
//  NSString+FileSize.m
//  Scholastic
//
//  Created by John S. Eddie on 03/04/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import "NSString+FileSize.h"

@implementation NSString (FileSize)

+ (id)stringWithSizeInGBFromBytes:(NSInteger)sizeInBytes
{
    NSString *ret = nil;

    if (sizeInBytes <= 0) {
        ret = [self stringWithFormat:@"0GB"];
    } else {
        ret = [self stringWithFormat:@"%.1fGB", sizeInBytes / 1000000000.0];
    }

    return ret;
}

@end
