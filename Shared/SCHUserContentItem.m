// 
//  SCHUserContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHUserContentItem.h"

#import "SCHContentProfileItem.h"
#import "SCHOrderItem.h"
#import "SCHContentMetadataItem.h"
#import "SCHBookIdentifier.h"

@implementation SCHUserContentItem 

@dynamic Format;
@dynamic Version;
@dynamic ContentIdentifier;
@dynamic ContentIdentifierType;
@dynamic DefaultAssignment;
@dynamic DRMQualifier;
@dynamic OrderList;
@dynamic ProfileList;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.ContentIdentifier
                                                               DRMQualifier:self.DRMQualifier];
    return [identifier autorelease];
}

- (NSSet *)ContentMetadataItem
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHContentMetadataItem 
                                        inManagedObjectContext:self.managedObjectContext]];	
    // note: ContentMetadataItem doesnt have a DRM Qualifier
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ContentIdentifier == %@", 
                                self.ContentIdentifier]];
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest 
                                                               error:nil];
    [fetchRequest release], fetchRequest = nil;
    
    return((result == nil ? [NSSet set] : [NSSet setWithArray:result]));
}

- (NSSet *)AssignedProfileList
{
	return(self.ProfileList);
}

@end
