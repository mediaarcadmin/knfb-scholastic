//
//  SCHStoryInteractionParser.h
//  StoryInteractions
//
//  Created by Neil Gall on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHXPSProvider;

@interface SCHStoryInteractionParser : NSObject {}

- (NSArray *)parseStoryInteractionsFromXPSProvider:(SCHXPSProvider *)xpsProvider;
- (NSArray *)parseStoryInteractionsFromData:(NSData *)data;

@end
