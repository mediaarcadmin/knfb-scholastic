// 
//  SCHAnnotationsItem.m
//  Scholastic
//
//  Created by John S. Eddie on 02/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHAnnotationsItem.h"

#import "SCHAnnotationsContentItem.h"
#import "SCHProfileItem.h"

// Constants
NSString * const kSCHAnnotationsItem = @"SCHAnnotationsItem";

NSString * const kSCHAnnotationsItemfetchAnnotationItemForProfile = @"fetchAnnotationItemForProfile";
NSString * const kSCHAnnotationsItemPROFILE_ID = @"PROFILE_ID";

@implementation SCHAnnotationsItem 

@dynamic ProfileID;
@dynamic AnnotationsContentItem;

- (SCHProfileItem *)profileItem
{
    SCHProfileItem *ret = nil;
    
    if (self.ProfileID != nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:kSCHProfileItem
                                            inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ID == %@", self.ProfileID]];
        
        NSArray *profiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        [fetchRequest release];
        
        if ([profiles count] > 0) {
            ret = [profiles objectAtIndex:0];                
        }
    }
    
    return ret;
}

@end
