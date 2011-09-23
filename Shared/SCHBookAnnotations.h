//
//  SCHBookAnnotations.h
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPrivateAnnotations;
@class SCHBookmark;
@class SCHHighlight;
@class SCHNote;
@class SCHLastPage;
@class SCHBookRange;

@interface SCHBookAnnotations : NSObject 
{    
}

- (id)initWithPrivateAnnotations:(SCHPrivateAnnotations *)privateAnnotations;

- (NSUInteger)bookmarksCount;
- (SCHBookmark *)bookmarkAtIndex:(NSUInteger)index;
- (void)deleteBookmark:(SCHBookmark *)bookmark;

- (NSUInteger)notesCount;
- (SCHNote *)noteAtIndex:(NSUInteger)index;
- (SCHNote *)createEmptyNote;
- (void)deleteNote:(SCHNote *)note;

- (NSUInteger)highlightsCount;
- (NSArray *)highlightsForPage:(NSUInteger)page;
- (SCHHighlight *)createEmptyHighlight;
- (SCHHighlight *)createHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord color:(UIColor *)color;
- (void)deleteHighlight:(SCHHighlight *)highlight;

- (SCHLastPage *)lastPage;

@end
