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
@class SCHBookStoryInteractions;

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
@property (nonatomic, assign) SCHBookStoryInteractions *bookStoryInteractions;

// YES if this is an interaction for older readers
- (BOOL)isOlderStoryInteraction;

// YES if this story interaction has all the necessary properties to be used
- (BOOL)isValid;

// Short story interaction title for the pop up list view
- (NSString *)title;

// Story interaction title for the interaction view itself
- (NSString *)interactionViewTitle;

// does this story interaction require interaction with the underlying page?
- (BOOL)requiresInteractionWithPage;

// XPS-relative paths; return nil if the particular audio is not required
- (NSString *)audioPathForQuestion;
- (NSString *)audioPathForThatsRight;
- (NSString *)audioPathForTryAgain;

// These returns filenames usable with [[NSBundle mainBundle] pathForResource:...]
- (NSString *)storyInteractionButtonAppearingSoundFilename;
- (NSString *)storyInteractionOpeningSoundFilename;
- (NSString *)storyInteractionCorrectAnswerSoundFilename;
- (NSString *)storyInteractionWrongAnswerSoundFilename;
- (NSString *)storyInteractionRevealSoundFilename;

// returns the number of questions contained within the interaction
// overridden in SCHStoryInteractionMultipleChoice subclass; this class returns 1.
- (NSInteger)questionCount;

@end
