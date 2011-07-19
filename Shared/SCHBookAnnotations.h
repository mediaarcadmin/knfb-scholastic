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
- (void)refreshData;

- (NSArray *)bookmarks;
- (void)deleteBookmark:(SCHBookmark *)bookmark;
- (NSArray *)highlightsForPage:(NSUInteger)page;
- (void)deleteHighlight:(SCHHighlight *)highlight;
- (NSArray *)notes;
- (void)deleteNote:(SCHNote *)note;
- (SCHLastPage *)lastPage;

- (SCHNote *)createEmptyNote;
- (SCHHighlight *)createEmptyHighlight;
- (SCHHighlight *)createHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord color:(UIColor *)color;

@end
