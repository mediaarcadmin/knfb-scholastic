//
//  SCHBookAnnotations.m
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookAnnotations.h"

#import "SCHPrivateAnnotations.h"
#import "SCHLibreAccessConstants.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHAnnotationsItem.h"
#import "SCHNote.h"
#import "SCHHighlight.h"
#import "SCHBookmark.h"
#import "SCHLocationText.h"
#import "SCHLocationGraphics.h"
#import "SCHWordIndex.h"
#import "SCHBookRange.h"
#import "SCHAppStateManager.h"

@interface SCHBookAnnotations ()

@property (nonatomic, retain) SCHPrivateAnnotations *privateAnnotations;
@property (nonatomic, retain, readonly) NSArray *sortedBookmarks;
@property (nonatomic, retain, readonly) NSArray *sortedHighlights;
@property (nonatomic, retain, readonly) NSArray *sortedNotes;

@end

@implementation SCHBookAnnotations

@synthesize privateAnnotations;
@synthesize sortedBookmarks;
@synthesize sortedHighlights;
@synthesize sortedNotes;

#pragma mark - Object lifecycle

- (id)initWithPrivateAnnotations:(SCHPrivateAnnotations *)aPrivateAnnotation
{
    self = [super init];
    if (self) {
        privateAnnotations = [aPrivateAnnotation retain];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(annotationSyncComponentDidCompleteNotification:) 
                                                     name:SCHAnnotationSyncComponentDidCompleteNotification 
                                                   object:nil];        
    }
    return(self);
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [privateAnnotations release], privateAnnotations = nil;
    [sortedBookmarks release], sortedBookmarks = nil;
    [sortedHighlights release], sortedHighlights = nil;
    [sortedNotes release], sortedNotes = nil;
    
    [super dealloc];
}

- (void)annotationSyncComponentDidCompleteNotification:(NSNotification *)notification
{
    NSNumber *profileID = [notification.userInfo objectForKey:SCHAnnotationSyncComponentCompletedProfileIDs];
    NSNumber *myProfileID = self.privateAnnotations.AnnotationsContentItem.AnnotationsItem.ProfileID;
    
    if (myProfileID) {
        if ([profileID isEqualToNumber:myProfileID] == YES) {
            [sortedBookmarks release], sortedBookmarks = nil;
            [sortedHighlights release], sortedHighlights = nil;
            [sortedNotes release], sortedNotes = nil;
        }
    } else {
        NSLog(@"Warning: unable to retrieve a profileID for this bookannotation - this is a memory leak");
    }
}

#pragma mark - Accessor methods

- (NSArray *)sortedBookmarks
{
    if (sortedBookmarks == nil) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        NSArray *allBookmarks = nil;
        
        if (self.privateAnnotations != nil) {
            allBookmarks = [self.privateAnnotations.Bookmarks sortedArrayUsingDescriptors:
                            [NSArray arrayWithObject:sortDescriptor]];
        } else {
            allBookmarks = [NSArray array];
        }
        
        // remove deleted objects
        sortedBookmarks = [[allBookmarks filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]] retain];                
    }

    return sortedBookmarks;
}


- (NSArray *)sortedHighlights
{
    if (sortedHighlights == nil) {
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLocationPage ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceEndPage ascending:YES];
        
        NSArray *allHighlights = nil;
        
        if (self.privateAnnotations != nil) {
            allHighlights = [self.privateAnnotations.Highlights sortedArrayUsingDescriptors:
                             [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        } else {
            allHighlights = [NSArray array];
        }
        
        // remove deleted objects
        sortedHighlights = [[allHighlights filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]] retain];        
    }
    
    return sortedHighlights;
}

- (NSArray *)sortedNotes
{
    if (sortedNotes == nil) {
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLocationPage ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLastModified ascending:YES];
        
        NSArray *allNotes = nil;
        
        if (self.privateAnnotations != nil) {
            allNotes = [self.privateAnnotations.Notes sortedArrayUsingDescriptors:
                        [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        } else {
            allNotes = [NSArray array];
        }
        
        // remove deleted objects
        sortedNotes = [[allNotes filteredArrayUsingPredicate:
                       [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]] retain];        
    }
    
    return sortedNotes;
}

#pragma mark - Bookmarks

- (NSUInteger)bookmarksCount
{
    return [self.sortedBookmarks count];
}

- (SCHBookmark *)bookmarkAtIndex:(NSUInteger)index
{
    if (index < [self.sortedBookmarks count]) {
        return [self.sortedBookmarks objectAtIndex:index];
    } else {
        return nil;
    }
}

- (void)deleteBookmark:(SCHBookmark *)bookmark
{
    if ([[SCHAppStateManager sharedAppStateManager] canSync] == NO) {
        [self.privateAnnotations removeBookmarksObject:bookmark];
    } else {
        if (bookmark.isDeleted == NO) {
            [bookmark syncDelete];    
        }
    }
    
    [sortedBookmarks release], sortedBookmarks = nil;
}

#pragma mark - Highlights

- (NSUInteger)highlightsCount
{
    return [self.sortedHighlights count];
}

- (NSArray *)highlightsForPage:(NSUInteger)page
{
    NSArray *ret = nil;
    __block BOOL found = NO;
    __block NSRange pageRange = NSMakeRange(0, 0);

    // search for page
    [[self sortedHighlights] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (([obj startLayoutPage] <= page) &&
            ([obj endLayoutPage] >= page)) {
            if (found == NO) {
                pageRange.location = idx;
                pageRange.length = 1;
                found = YES;
            } else {
                pageRange.length++;
            }
        } else if (found == YES) {
            *stop = YES;
        }
    }];
    
    if (found == YES && 
        pageRange.length > 0 && NSMaxRange(pageRange) <= [self.sortedHighlights count]) {
        ret = [self.sortedHighlights subarrayWithRange:pageRange];
    }
    
    return(ret);
}

- (SCHHighlight *)createEmptyHighlight
{
    SCHHighlight *highlight = nil;
    
    if (self.privateAnnotations != nil) {
        highlight = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight 
                                                  inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        SCHLocationText *locationText = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationText
                                                                      inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        SCHWordIndex *wordIndex = [NSEntityDescription insertNewObjectForEntityForName:kSCHWordIndex
                                                                inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        locationText.WordIndex = wordIndex;
        
        highlight.PrivateAnnotations = self.privateAnnotations;
        highlight.Location = locationText;
        
        [sortedHighlights release], sortedHighlights = nil;
	}
    
	return highlight;
}

- (SCHHighlight *)createHighlightBetweenStartPage:(NSUInteger)startPage 
                                        startWord:(NSUInteger)startWord 
                                          endPage:(NSUInteger)endPage 
                                          endWord:(NSUInteger)endWord 
                                            color:(UIColor *)color
{
    SCHHighlight *newHighlight = [self createEmptyHighlight];
    
    if (newHighlight != nil) {
        newHighlight.EndPage = [NSNumber numberWithInteger:endPage];
        newHighlight.HighlightColor = color;
        newHighlight.Location.Page = [NSNumber numberWithInteger:startPage];
        newHighlight.Location.WordIndex.Start = [NSNumber numberWithInteger:startWord];
        newHighlight.Location.WordIndex.End = [NSNumber numberWithInteger:endWord];
        
        [sortedHighlights release], sortedHighlights = nil;
    }
    
    return newHighlight;
}

- (void)deleteHighlight:(SCHHighlight *)highlight
{
    if ([[SCHAppStateManager sharedAppStateManager] canSync] == NO) {
        [self.privateAnnotations removeHighlightsObject:highlight];
    } else {
        if (highlight.isDeleted == NO) {
            [highlight syncDelete];
        }
    }
    
    [sortedHighlights release], sortedHighlights = nil;
}

#pragma mark - Notes

- (NSUInteger)notesCount
{
    return [self.sortedNotes count];
}

- (SCHNote *)noteAtIndex:(NSUInteger)index
{
    if (index < [self.sortedNotes count]) {
        return [self.sortedNotes objectAtIndex:index];
    } else {
        return nil;
    }
}

- (SCHNote *)createEmptyNote
{
    SCHNote *note = nil;
    
    if (self.privateAnnotations != nil) {
        note = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                             inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        SCHLocationGraphics *locationGraphics = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics
                                                                              inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        note.PrivateAnnotations = self.privateAnnotations;
        note.NoteColor = [UIColor whiteColor];
        note.Location = locationGraphics;
        note.NoteText = @"";
        
        [sortedNotes release], sortedNotes = nil;
	}
    
	return note;
}

- (void)deleteNote:(SCHNote *)note
{
    if ([[SCHAppStateManager sharedAppStateManager] canSync] == NO) {
        [self.privateAnnotations removeNotesObject:note];
    } else {
        if (note.isDeleted == NO) {
            [note syncDelete];
        }
    }
    
    [sortedNotes release], sortedNotes = nil;
}

- (SCHLastPage *)lastPage
{
    return self.privateAnnotations.LastPage;
}

@end
