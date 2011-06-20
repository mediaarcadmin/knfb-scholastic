//
//  NSArray+Shuffling.m
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSArray+Shuffling.h"


@implementation NSArray (Shuffling)

- (NSArray *)shuffled
{
    if ([self count] < 2) {
        return self;
    }
    
    NSMutableArray *shuffled = [NSMutableArray arrayWithArray:self];
    do {
        for (NSInteger i = 1, n = [shuffled count]; i < n; ++i) {
            NSInteger pos = arc4random() % i;
            id object = [shuffled objectAtIndex:pos];
            [shuffled replaceObjectAtIndex:pos withObject:[shuffled objectAtIndex:i]];
            [shuffled replaceObjectAtIndex:i withObject:object];
        }
    } while ([shuffled isEqual:self]);
    
    return [NSArray arrayWithArray:shuffled];
}

@end
