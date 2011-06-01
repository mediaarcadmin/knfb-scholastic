//
//  SCHStoryInteraction.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHXPSProvider;
@class SCHStoryInteraction;

@interface SCHStoryInteractionQuestion : NSObject {}

@property (nonatomic, assign) SCHStoryInteraction *storyInteraction;
@property (nonatomic, assign) NSInteger questionIndex;

- (NSString *)audioPathForThatsRight;

@end

@interface SCHStoryInteraction : NSObject {}

@property (nonatomic, retain) NSString *ID;
@property (nonatomic, assign) NSInteger documentPageNumber;
@property (nonatomic, assign) CGPoint position;

// base path for interaction resources in XPSProvider
+ (NSString *)resourcesPath;

// an array of all the SCHStoryInteractions from the XPS provider
+ (NSArray *)storyInteractionsFromXpsProvider:(SCHXPSProvider *)xpsProvider;

@end
