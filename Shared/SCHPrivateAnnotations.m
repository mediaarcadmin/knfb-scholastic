// 
//  SCHPrivateAnnotations.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHPrivateAnnotations.h"

#import "SCHAnnotationsContentItem.h"
#import "SCHBookmark.h"
#import "SCHFavorite.h"
#import "SCHHighlight.h"
#import "SCHLastPage.h"
#import "SCHNote.h"

@implementation SCHPrivateAnnotations 

@dynamic LastPage;
@dynamic AnnotationsContentItem;
@dynamic Bookmarks;
@dynamic Highlights;
@dynamic Notes;
@dynamic Favorite;

#pragma -
#pragma Core Data Generated Accessors

- (void)addBookmarksObject:(SCHBookmark *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Bookmarks"] addObject:value];
    [self didChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeBookmarksObject:(SCHBookmark *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Bookmarks"] removeObject:value];
    [self didChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addBookmarks:(NSSet *)value {    
    [self willChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Bookmarks"] unionSet:value];
    [self didChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeBookmarks:(NSSet *)value {
    [self willChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Bookmarks"] minusSet:value];
    [self didChangeValueForKey:@"Bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)addHighlightsObject:(SCHHighlight *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Highlights"] addObject:value];
    [self didChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeHighlightsObject:(SCHHighlight *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Highlights"] removeObject:value];
    [self didChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addHighlights:(NSSet *)value {    
    [self willChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Highlights"] unionSet:value];
    [self didChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeHighlights:(NSSet *)value {
    [self willChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Highlights"] minusSet:value];
    [self didChangeValueForKey:@"Highlights" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)addNotesObject:(SCHNote *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Notes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Notes"] addObject:value];
    [self didChangeValueForKey:@"Notes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeNotesObject:(SCHNote *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"Notes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"Notes"] removeObject:value];
    [self didChangeValueForKey:@"Notes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addNotes:(NSSet *)value {    
    [self willChangeValueForKey:@"Notes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Notes"] unionSet:value];
    [self didChangeValueForKey:@"Notes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeNotes:(NSSet *)value {
    [self willChangeValueForKey:@"Notes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"Notes"] minusSet:value];
    [self didChangeValueForKey:@"Notes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
