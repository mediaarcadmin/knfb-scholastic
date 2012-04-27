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
@dynamic LastBookmarkAnnotationSync;
@dynamic LastHighlightAnnotationSync;
@dynamic LastNoteAnnotationSync;

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
    // default IsNewBook to YES and then we calculate the value once we have the 
    // annotations. After its no longer a new book we never perform the check.
    if ([ret boolValue] == YES) {
        SCHLastPage *lastPage = [self.ProfileItem annotationsForBook:[self bookIdentifier]].lastPage;
        NSDate *assignmentDate = self.ContentProfileItem.LastModified;
        NSDate *lastReadDate = lastPage.LastModified;
        if (assignmentDate != nil && lastReadDate != nil &&
            [assignmentDate laterDate:lastReadDate] == lastReadDate) {
            ret = [NSNumber numberWithBool:NO];
            self.IsNewBook = ret;
        }
    }
    
    return ret;    
}

@end
