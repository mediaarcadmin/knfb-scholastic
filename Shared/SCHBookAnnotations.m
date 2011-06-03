//
//  SCHBookAnnotations.m
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookAnnotations.h"

#import "SCHPrivateAnnotations.h"
#import "SCHLibreAccessWebService.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHNote.h"
#import "SCHHighlight.h"
#import "SCHLocationText.h"
#import "SCHLocationGraphics.h"
#import "SCHWordIndex.h"
#import "SCHBookRange.h"

@interface SCHBookAnnotations ()

@property (nonatomic, retain) SCHPrivateAnnotations *privateAnnotations;
@property (nonatomic, retain) NSArray *sortedBookmarks;
@property (nonatomic, retain) NSArray *sortedHighlights;
@property (nonatomic, retain) NSArray *sortedNotes;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kSCHAnnotationSyncComponentComplete object:nil];        
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

- (void)refreshData
{
    self.sortedBookmarks = nil;
    self.sortedHighlights = nil;
    self.sortedNotes = nil;
}

#pragma mark - Accessor methods

- (NSArray *)bookmarks
{
    if (self.sortedBookmarks == nil) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        self.sortedBookmarks = [self.privateAnnotations.Bookmarks sortedArrayUsingDescriptors:
                           [NSArray arrayWithObject:sortDescriptor]];
        
        // remove deleted objects
        self.sortedBookmarks = [self.sortedHighlights filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]];                
    }

    return(self.sortedBookmarks);
}

- (void)addBookmark:(SCHBookmark *)newBookmark
{
    [self.privateAnnotations addBookmarksObject:newBookmark];
}

- (void)deleteBookmark:(SCHBookmark *)bookmark
{
    [bookmark syncDelete];    
}

- (NSArray *)highlightsForPage:(NSUInteger)page
{
    NSArray *ret = nil;
    __block BOOL found = NO;
    __block NSRange pageRange = NSMakeRange(0, 0);

    if (self.sortedHighlights == nil) {
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLocationPage ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceEndPage ascending:YES];
        self.sortedHighlights = [self.privateAnnotations.Highlights sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        
        // remove deleted objects
        self.sortedHighlights = [self.sortedHighlights filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]];        
    }

    // search for page
    [self.sortedHighlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    
    if (found == YES) {
        ret = [self.sortedHighlights subarrayWithRange:pageRange];
    }
    
    return(ret);
}

- (void)addHighlight:(SCHHighlight *)newHighlight
{
    [self.privateAnnotations addHighlightsObject:newHighlight];
}

- (void)deleteHighlight:(SCHHighlight *)highlight
{
    [highlight syncDelete];
}

- (NSArray *)notes
{
    if (self.sortedNotes == nil) {
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLocationPage ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceLastModified ascending:YES];

        self.sortedNotes = [self.privateAnnotations.Notes sortedArrayUsingDescriptors:
                          [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        
        // remove deleted objects
        self.sortedNotes = [self.sortedNotes filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]];        
    }
    
    return(self.sortedNotes);
}

- (void)addNote:(SCHNote *)newNote
{
    [self.privateAnnotations addNotesObject:newNote];
}

- (void)deleteNote:(SCHNote *)note
{
    [note syncDelete];
}

- (SCHFavorite *)favorite
{
    return(self.privateAnnotations.Favorite);
}

- (SCHLastPage *)lastPage
{
    return(self.privateAnnotations.LastPage);
}

- (SCHNote *)createEmptyNote
{
    SCHNote *note = [NSEntityDescription insertNewObjectForEntityForName:kSCHNote 
                                            inManagedObjectContext:self.privateAnnotations.managedObjectContext];
        
    SCHLocationGraphics *locationGraphics = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationGraphics
                                                                  inManagedObjectContext:self.privateAnnotations.managedObjectContext];
                                     
    note.PrivateAnnotations = self.privateAnnotations;
    note.Color = [UIColor whiteColor];
    note.Location = locationGraphics;
    note.NoteText = @"";
	
	return note;
}

- (SCHHighlight *)createEmptyHighlight
{
    SCHHighlight *highlight = [NSEntityDescription insertNewObjectForEntityForName:kSCHHighlight 
                                                  inManagedObjectContext:self.privateAnnotations.managedObjectContext];
    
    SCHLocationText *locationText = [NSEntityDescription insertNewObjectForEntityForName:kSCHLocationText
                                                                  inManagedObjectContext:self.privateAnnotations.managedObjectContext];
    
    SCHWordIndex *wordIndex = [NSEntityDescription insertNewObjectForEntityForName:kSCHWordIndex
                                                            inManagedObjectContext:self.privateAnnotations.managedObjectContext];
    
    locationText.WordIndex = wordIndex;
    
    highlight.PrivateAnnotations = self.privateAnnotations;
    highlight.Location = locationText;
	
	return highlight;
}

- (SCHHighlight *)createHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord color:(UIColor *)color
{
    SCHHighlight *newHighlight = [self createEmptyHighlight];
    newHighlight.EndPage = [NSNumber numberWithInteger:endPage];
    newHighlight.Color = color;
    newHighlight.Location.Page = [NSNumber numberWithInteger:startPage];
    newHighlight.Location.WordIndex.Start = [NSNumber numberWithInteger:startWord];
    newHighlight.Location.WordIndex.End = [NSNumber numberWithInteger:endWord];
    
    return newHighlight;
}

// FIXME: remove this - it doesn't take into account the block offset
- (SCHHighlight *)createHighlightWithHighlightRange:(SCHBookRange *)highlightRange color:(UIColor *)color
{
    SCHHighlight *newHighlight = [self createEmptyHighlight];
    newHighlight.EndPage = [NSNumber numberWithInteger:highlightRange.endPoint.layoutPage];
    newHighlight.Color = color;
    newHighlight.Location.Page = [NSNumber numberWithInteger:highlightRange.startPoint.layoutPage];
    newHighlight.Location.WordIndex.Start = [NSNumber numberWithInteger:highlightRange.startPoint.wordOffset];
    newHighlight.Location.WordIndex.End = [NSNumber numberWithInteger:highlightRange.endPoint.wordOffset];
    
    return newHighlight;
}

@end
