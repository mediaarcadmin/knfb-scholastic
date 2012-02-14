// 
//  SCHUserContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHUserContentItem.h"

//#import "SCHContentProfileItem.h"
#import "SCHOrderItem.h"
#import "SCHContentMetadataItem.h"
#import "SCHBookIdentifier.h"

// Constants
NSString * const kSCHUserContentItem = @"SCHUserContentItem";

NSString * const kSCHUserContentItemFetchWithContentIdentifier = @"fetchUserContentItemWithContentIdentifier";
NSString * const kSCHUserContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHUserContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@implementation SCHUserContentItem 

@dynamic Format;
@dynamic Version;
@dynamic ContentIdentifier;
@dynamic ContentIdentifierType;
@dynamic DefaultAssignment;
@dynamic DRMQualifier;
@dynamic OrderList;
@dynamic ProfileList;
@dynamic FreeBook;
@dynamic LastVersion;
@dynamic AverageRating;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.ContentIdentifier
                                                               DRMQualifier:self.DRMQualifier];
    return [identifier autorelease];
}

- (NSSet *)ContentMetadataItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@ AND DRMQualifier == %@", 
                                self.ContentIdentifier, self.DRMQualifier]];
    
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (result == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
}

- (NSSet *)AssignedProfileList
{
	return(self.ProfileList);
}

@end
