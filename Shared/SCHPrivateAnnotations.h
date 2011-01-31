//
//  SCHPrivateAnnotations.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHAnnotationsContentItem;
@class SCHBookmark;
@class SCHFavorite;
@class SCHHighlight;
@class SCHLastPage;
@class SCHNote;

@interface SCHPrivateAnnotations :  NSManagedObject  
{
}

@property (nonatomic, retain) SCHLastPage * LastPage;
@property (nonatomic, retain) SCHAnnotationsContentItem * AnnotationsContentItem;
@property (nonatomic, retain) NSSet* Bookmarks;
@property (nonatomic, retain) NSSet* Highlights;
@property (nonatomic, retain) NSSet* Notes;
@property (nonatomic, retain) SCHFavorite * Favorite;

@end


@interface SCHPrivateAnnotations (CoreDataGeneratedAccessors)
- (void)addBookmarksObject:(SCHBookmark *)value;
- (void)removeBookmarksObject:(SCHBookmark *)value;
- (void)addBookmarks:(NSSet *)value;
- (void)removeBookmarks:(NSSet *)value;

- (void)addHighlightsObject:(SCHHighlight *)value;
- (void)removeHighlightsObject:(SCHHighlight *)value;
- (void)addHighlights:(NSSet *)value;
- (void)removeHighlights:(NSSet *)value;

- (void)addNotesObject:(SCHNote *)value;
- (void)removeNotesObject:(SCHNote *)value;
- (void)addNotes:(NSSet *)value;
- (void)removeNotes:(NSSet *)value;

@end

