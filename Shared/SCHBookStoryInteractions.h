//
//  SCHBookStoryInteractions.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHXPSProvider;

@interface SCHBookStoryInteractions : NSObject {}

@property (nonatomic, readonly) NSArray *allStoryInteractions;

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider;

- (NSArray *)storyInteractionsForPage:(NSInteger)pageNumber;

@end
