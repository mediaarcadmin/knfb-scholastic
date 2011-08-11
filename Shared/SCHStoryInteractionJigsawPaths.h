//
//  SCHStoryInteractionJigsawPaths.h
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHStoryInteractionJigsawPaths : NSObject {}

- (id)initWithData:(NSData *)data;

- (NSInteger)numberOfPaths;
- (CGPathRef)pathAtIndex:(NSInteger)pathIndex;

@end
