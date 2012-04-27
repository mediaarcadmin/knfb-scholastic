//
//  SCHStoryInteraction.h
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionPageAssociation.h"
#import "KNFBXPSConstants.h"

@class SCHXPSProvider;
@class SCHStoryInteraction;
@class SCHBookStoryInteractions;

@interface SCHStoryInteractionQuestion : NSObject {}

@property (nonatomic, assign) SCHStoryInteraction *storyInteraction;
@property (nonatomic, assign) NSInteger questionIndex;

@end

@interface SCHStoryInteraction : NSObject {}

@property (nonatomic, retain) NSString *ID;
@property (nonatomic, assign) NSInteger documentPageNumber;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) SCHBookStoryInteractions *bookStoryInteractions;
@property (nonatomic, assign, getter=isOlderStoryInteraction) BOOL olderStoryInteraction;

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
// - should be overidden in subclasses
- (NSInteger)questionCount;

// where questions are split across pages, the page associated with each question index
// - should be overidden in subclasses
- (enum SCHStoryInteractionQuestionPageAssociation)pageAssociationForQuestionAtIndex:(NSInteger)questionIndex
                                                                        withPageSize:(CGSize)pageSize;

- (BOOL)hasQuestionsOnLeftPageForPageSize:(CGSize)pageSize;
- (BOOL)hasQuestionsOnRightPageForPageSize:(CGSize)pageSize;
- (NSInteger)numberOfQuestionsWithPageAssociation:(enum SCHStoryInteractionQuestionPageAssociation)pageAssociation withPageSize:(CGSize)pageSize;

// YES if this story interaction always asks a new question each time; NO if each question
// must be completed correctly before moving on
- (BOOL)alwaysIncrementsQuestionIndex;

@end
