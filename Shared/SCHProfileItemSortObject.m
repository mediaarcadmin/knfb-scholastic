//
//  SCHProfileItemSortObject.m
//  Scholastic
//
//  Created by John Eddie on 20/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHProfileItemSortObject.h"

@implementation SCHProfileItemSortObject

@synthesize item;
@synthesize date;
@synthesize isNewBook;

- (void)dealloc 
{
    [item release], item = nil;
    [date release], date = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@ %@", self.item, self.date, 
            (self.isNewBook == YES ? @"New" : @"") ];
}

@end
