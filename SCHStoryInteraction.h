//
//  SCHStoryInteraction.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHXPSProvider;

@interface SCHStoryInteraction : NSObject {}

@property (nonatomic, assign) NSInteger documentPageNumber;
@property (nonatomic, assign) CGPoint position;

// an array of all the SCHStoryInteractions from the XPS provider
+ (NSArray *)storyInteractionsFromXpsProvider:(SCHXPSProvider *)xpsProvider;

@end
