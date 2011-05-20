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

- (NSArray *)highlightsForPage:(NSUInteger)page
{
    NSArray *ret = nil;
    __block BOOL found = NO;
    __block NSRange pageRange = NSMakeRange(0, 0);

    if (self.sortedHighlights == nil) {
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceStart ascending:YES];
        self.sortedHighlights = [self.privateAnnotations.Highlights sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
        
        // remove deleted objects
        self.sortedHighlights = [self.sortedHighlights filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]];        
    }

    // search for page
    [self.sortedHighlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj page] integerValue] == page) {
            if (found == NO) {
                pageRange.location = idx;
                found = YES;
            } else {
                pageRange.length = pageRange.length + 1;
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

- (NSArray *)notes
{
    if (self.sortedNotes == nil) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        self.sortedNotes = [self.privateAnnotations.Notes sortedArrayUsingDescriptors:
                          [NSArray arrayWithObject:sortDescriptor]];
        
        // remove deleted objects
        self.sortedNotes = [self.sortedHighlights filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"State != %@", [NSNumber numberWithStatus:kSCHStatusDeleted]]];        
    }
    
    return(self.sortedNotes);
}

- (void)addNote:(SCHNote *)newNote
{
    [self.privateAnnotations addNotesObject:newNote];
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
	
	return note;
}

@end
