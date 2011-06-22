//
//  SCHBookRange.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookRange.h"

@implementation SCHBookRange

@synthesize startPoint;
@synthesize endPoint;

- (void)dealloc
{
    [startPoint release], startPoint = nil;
    [endPoint release], endPoint = nil;
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    SCHBookRange *otherRange = (SCHBookRange *)object;
    
    if ((otherRange.startPoint.layoutPage == self.startPoint.layoutPage) &&
        (otherRange.startPoint.blockOffset == self.startPoint.blockOffset) &&
        (otherRange.startPoint.wordOffset == self.startPoint.wordOffset) &&
        (otherRange.startPoint.elementOffset == self.startPoint.elementOffset) &&
        (otherRange.endPoint.layoutPage == self.endPoint.layoutPage) &&
        (otherRange.endPoint.blockOffset == self.endPoint.blockOffset) &&
        (otherRange.endPoint.wordOffset == self.endPoint.wordOffset) &&
        (otherRange.endPoint.elementOffset == self.endPoint.elementOffset)) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHBookRange: %p> %@ -- %@", self, self.startPoint, self.endPoint];
}

@end
