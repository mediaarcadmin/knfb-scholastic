//
//  NSArray+Shuffling.h
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Shuffling)

// shuffle an array, with a guarantee the original order will not be returned
- (NSArray *)shuffled;

@end
