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
#import "SCHRating.h"

@interface SCHBookAnnotations ()

@property (nonatomic, retain) SCHPrivateAnnotations *privateAnnotations;
@property (nonatomic, retain, readonly) NSArray *sortedBookmarks;
@property (nonatomic, retain, readonly) NSArray *sortedHighlights;
@property (nonatomic, retain, readonly) NSArray *sortedNotes;
@property (nonatomic, retain) NSNumber *cachedProfileID;

@end

@implementation SCHBookAnnotations

@synthesize privateAnnotations;
@synthesize sortedBookmarks;
@synthesize sortedHighlights;
@synthesize sortedNotes;
@synthesize cachedProfileID;

#pragma mark - Object lifecycle

- (id)initWithPrivateAnnotations:(SCHPrivateAnnotations *)aPrivateAnnotation
{
    self = [super init];
    if (self) {
        privateAnnotations = [aPrivateAnnotation retain];
        cachedProfileID = [privateAnnotations.AnnotationsContentItem.AnnotationsItem.ProfileID retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(annotationSyncComponentDidCompleteNotification:) 
                                                     name:SCHAnnotationSyncComponentDidCompleteNotification 
                                                   object:nil];        
        
        if (self.privateAnnotations.managedObjectContext != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(managedObjectContextDidSaveNotification:) 
                                                         name:NSManagedObjectContextDidSaveNotification 
                                                       object:self.privateAnnotations.managedObjectContext];                    
        }
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
    [cachedProfileID release], cachedProfileID = nil;
    
    [super dealloc];
}

- (void)annotationSyncComponentDidCompleteNotification:(NSNotification *)notification
{
    NSNumber *profileID = [notification.userInfo objectForKey:SCHAnnotationSyncComponentProfileIDs];
    
    if (self.cachedProfileID) {
        if ([profileID isEqualToNumber:self.cachedProfileID] == YES) {
            [sortedBookmarks release], sortedBookmarks = nil;
            [sortedHighlights release], sortedHighlights = nil;
            [sortedNotes release], sortedNotes = nil;
        }
    } else {
        NSLog(@"Warning: unable to retrieve a cachedProfileID for this bookannotation");
    }
}

- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification
{
    NSAssert([NSThread isMainThread] == YES, @"SCHBookAnnotation:managedObjectContextDidSaveNotification MUST be executed on the main thread");
    
    if (self.privateAnnotations != nil) {
        NSArray *deletedObjects = [notification.userInfo objectForKey:NSDeletedObjectsKey];    
        
        if ([deletedObjects containsObject:self.privateAnnotations] == YES) {
            self.privateAnnotations = nil;
            [sortedBookmarks release], sortedBookmarks = nil;
            [sortedHighlights release], sortedHighlights = nil;
            [sortedNotes release], sortedNotes = nil;
        }
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

// This is a scratch version of a SCHNote designed to be created on an independant
// NSManagedObjectContext and then when the user saves it provided to createNoteWithNote
// to create the Note for real
// Note: this SCHNote is identified by privateAnnotations = nil
- (SCHNote *)createEmptyScratchNoteInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    SCHNote *note = nil;
    
    if (managedObjectContext != nil) {
        note = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                             inManagedObjectContext:managedObjectContext];
        
        SCHLocationGraphics *locationGraphics = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics
                                                                              inManagedObjectContext:managedObjectContext];
        
        note.NoteColor = [UIColor whiteColor];
        note.Location = locationGraphics;        
        note.NoteText = @"";
	}
    
	return note;
}

- (SCHNote *)createNoteWithNote:(SCHNote *)scratchNote
{
    SCHNote *note = nil;
    
    if (scratchNote != nil && self.privateAnnotations != nil) {
        note = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                             inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        SCHLocationGraphics *locationGraphics = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics
                                                                              inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
        note.PrivateAnnotations = self.privateAnnotations;
        note.NoteColor = scratchNote.NoteColor;
        note.Location = locationGraphics;
        note.noteLayoutPage = scratchNote.noteLayoutPage;        
        note.NoteText = scratchNote.NoteText;
        note.Version = scratchNote.Version;
        
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

- (void)setUserRating:(NSInteger)userRating
{
    self.privateAnnotations.rating.rating = [NSNumber numberWithInteger:userRating];
}

- (NSInteger)userRating
{
    return [self.privateAnnotations.rating.rating integerValue];
}

@end
