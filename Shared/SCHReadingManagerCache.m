//
//  SCHReadingManagerCache.m
//  Scholastic
//
//  Created by Matt Farrugia on 16/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHReadingManagerCache.h"

@implementation SCHReadingManagerCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    //NSLog(@"Ignoring cache for %@", request);
    return nil;
}

@end