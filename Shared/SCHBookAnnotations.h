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
@class SCHFavorite;
@class SCHLastPage;
@class SCHBookRange;

@interface SCHBookAnnotations : NSObject 
{    
}

- (id)initWithPrivateAnnotations:(SCHPrivateAnnotations *)privateAnnotations;

- (NSArray *)bookmarks;
- (void)addBookmark:(SCHBookmark *)newBookmark;
- (NSArray *)highlightsForPage:(NSUInteger)page;
- (void)addHighlight:(SCHHighlight *)newHighlight;
- (NSArray *)notes;
- (void)addNote:(SCHNote *)newNote;
- (SCHFavorite *)favorite;
- (SCHLastPage *)lastPage;

// Convenience creation methods
// FIXME: Confirm this fits with the sync model with John

- (SCHNote *)createEmptyNote;
- (SCHHighlight *)createEmptyHighlight;
- (SCHHighlight *)createHighlightWithHighlightRange:(SCHBookRange *)highlightRange color:(UIColor *)color;

@end
