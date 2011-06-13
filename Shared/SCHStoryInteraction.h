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

// TODO: move to KNFBXPSConstants module
extern NSString * const KNFBXPSStoryInteractionsDirectory;

@interface SCHStoryInteractionQuestion : NSObject {}

@property (nonatomic, assign) SCHStoryInteraction *storyInteraction;
@property (nonatomic, assign) NSInteger questionIndex;

@end

@interface SCHStoryInteraction : NSObject {}

@property (nonatomic, retain) NSString *ID;
@property (nonatomic, assign) NSInteger documentPageNumber;
@property (nonatomic, assign) CGPoint position;

// YES if this is an interaction for older readers
- (BOOL)isOlderStoryInteraction;

// Short story interaction title for the pop up list view
- (NSString *)title;

// Story interaction title for the interaction view itself
- (NSString *)interactionViewTitle;

- (NSString *)storyInteractionButtonAppearingSoundFilename;
- (NSString *)storyInteractionOpeningSoundFilename;
- (NSString *)audioPathForThatsRight;
- (NSString *)audioPathForTryAgain;
- (NSString *)storyInteractionCorrectAnswerSoundFilename;
- (NSString *)storyInteractionWrongAnswerSoundFilename;

@end
