//
//  SCHBookPoint.m
//  Scholastic
//
//  Created by Matt Farrugia on 28/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookPoint.h"


@implementation SCHBookPoint

@synthesize layoutPage;
@synthesize blockOffset;
@synthesize wordOffset;
@synthesize elementOffset;

- (NSComparisonResult)compare:(SCHBookPoint *)rhs
{
    NSInteger comparison = self.layoutPage - rhs.layoutPage;
    if(comparison < 0) {
        return NSOrderedAscending;
    } else if (comparison > 0) {
        return NSOrderedDescending;
    } else {            
        comparison = self.blockOffset - rhs.blockOffset;
        if(comparison < 0) {
            return NSOrderedAscending;
        } else if (comparison > 0) {
            return NSOrderedDescending;
        } else {            
            comparison = self.wordOffset - rhs.wordOffset;
            if(comparison < 0) {
                return NSOrderedAscending;
            } else if (comparison > 0) {
                return NSOrderedDescending;
            } else {            
                comparison = self.elementOffset - rhs.elementOffset;
                if(comparison < 0) {
                    return NSOrderedAscending;
                } else if (comparison > 0) {
                    return NSOrderedDescending;
                } else {            
                    return NSOrderedSame;
                }
            }        
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<SCHBookPoint: %p> [%d %d %d %d]", self, self.layoutPage, self.blockOffset, self. wordOffset, self.elementOffset];
}

@end
