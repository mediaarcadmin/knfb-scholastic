//
//  SCHAppContentProfileItem.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppContentProfileItem.h"

#import "SCHProfileItem.h"
#import "SCHBookIdentifier.h"
#import "SCHBookAnnotations.h"
#import "SCHContentProfileItem.h"
#import "SCHLastPage.h"
#import "NSDate+LibreAccessEarliestDate.h"

// Constants
NSString * const kSCHAppContentProfileItem = @"SCHAppContentProfileItem";

NSString * const kSCHAppContentProfileItemDRMQualifier = @"DRMQualifier";
NSString * const kSCHAppContentProfileItemISBN = @"ISBN";
NSString * const kSCHAppContentProfileItemOrder = @"Order";

@implementation SCHAppContentProfileItem

@dynamic DRMQualifier;
@dynamic ISBN;
@dynamic IsNewBook;
@dynamic Order;
@dynamic pageRead;
@dynamic bestScore;
@dynamic LastBookmarkAnnotationSync;
@dynamic LastHighlightAnnotationSync;
@dynamic LastNoteAnnotationSync;
@dynamic lastOpenedDate;

@dynamic ProfileItem;
@dynamic ContentProfileItem;

@synthesize bookIdentifier;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.ISBN
                                                               DRMQualifier:self.DRMQualifier];
    return([identifier autorelease]);
}

- (NSNumber *)IsNewBook
{
    [self willAccessValueForKey:@"IsNewBook"];
    NSNumber *ret = [self primitiveValueForKey:@"IsNewBook"];
    [self didAccessValueForKey:@"IsNewBook"];
    
    // Because the annotation sync happens a little later in the sync process we
    // default IsNewBook to nil. 
    // The check happens if that value is nil, or if it's YES (i.e. still a new book)
    // After its no longer a new book, so do not need to check
    if (!ret || [ret boolValue] == YES) {
        SCHLastPage *lastPage = [self.ProfileItem annotationsForBook:[self bookIdentifier]].lastPage;
        
        NSDate *assignmentDate = self.ContentProfileItem.LastModified;
        NSDate *lastReadDate = lastPage.LastModified;
        
        // if any of these haven't been set, or the last read date hasn't been
        // set (SCHLibreAccessEarliestDate), then we'll temporarily return NO
        if (!lastPage || !assignmentDate || !lastReadDate ||
            [[NSDate SCHLibreAccessEarliestDate] isEqualToDate:lastReadDate]) {
            ret = [NSNumber numberWithBool:NO];
        } else if ([assignmentDate laterDate:lastReadDate] == lastReadDate) {
        // otherwise, if the last read date is later than the assignment date, return NO and save it
            ret = [NSNumber numberWithBool:NO];
            self.IsNewBook = ret;
        } else {
        // otherwise, return YES and save it - we'll check again later if the book has been read
            ret = [NSNumber numberWithBool:YES];
            self.IsNewBook = ret;
        }
    }
    
    return ret;    
}

// only set the best score if it's better than the current best score
- (void)setBestScore:(NSNumber *)value
{
    if (value != nil) {
        NSNumber *currentBestScore = [self primitiveValueForKey:@"bestScore"];
        
        if (currentBestScore == nil ||
            [value integerValue] > [currentBestScore integerValue]) {
            [self willChangeValueForKey:@"bestScore"];
            [self setPrimitiveValue:value forKey:@"bestScore"];
            [self didChangeValueForKey:@"bestScore"];
        }
    }
}

- (void)openedBook
{
    self.lastOpenedDate = [NSDate date];
}

@end
