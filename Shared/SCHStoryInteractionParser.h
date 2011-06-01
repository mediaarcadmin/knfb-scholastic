//
//  SCHStoryInteractionParser.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHStoryInteractionParser : NSObject {}

- (NSArray *)parseStoryInteractionsFromData:(NSData *)data;

@end
