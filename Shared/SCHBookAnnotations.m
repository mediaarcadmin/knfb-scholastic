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
    }
    return(self);
}

- (void)dealloc 
{
    [privateAnnotations release], privateAnnotations = nil;
    [sortedBookmarks release], sortedBookmarks = nil;
    [sortedHighlights release], sortedHighlights = nil;
    [sortedNotes release], sortedNotes = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (NSArray *)bookmarks
{
    if (self.sortedBookmarks == nil) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        self.sortedBookmarks = [self.privateAnnotations.Bookmarks sortedArrayUsingDescriptors:
                           [NSArray arrayWithObject:sortDescriptor]];
    }

    return(self.sortedBookmarks);
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
    }

    // search for page
    [self.sortedHighlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
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

- (NSArray *)notes
{
    if (self.sortedNotes == nil) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServicePage ascending:YES];
        self.sortedNotes = [self.privateAnnotations.Notes sortedArrayUsingDescriptors:
                          [NSArray arrayWithObject:sortDescriptor]];
    }
    
    return(self.sortedNotes);
}

- (SCHFavorite *)favorite
{
    return(self.privateAnnotations.Favorite);
}

- (SCHLastPage *)lastPage
{
    return(self.privateAnnotations.LastPage);
}

@end
