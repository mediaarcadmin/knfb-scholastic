//
//  NSManagedObjectContext+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 24/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSManagedObjectContext+Extensions.h"

static NSUInteger const kNSManagedObjectContextBITBatchCount = 250;

@implementation NSManagedObjectContext (Extensions)

- (BOOL)BITemptyEntity:(NSString *)entityName error:(NSError **)error
{
	BOOL ret = NO;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSUInteger batchCount = 0;
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self]];	
	
	NSArray *results = [self executeFetchRequest:fetchRequest error:error];
    if (results == nil) {
        NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    }
    
	for (NSManagedObject *managedObject in results) {
		[self deleteObject:managedObject];
        batchCount++;
        if (batchCount >= kNSManagedObjectContextBITBatchCount) {
            batchCount = 0;
            ret = [self save:error];   
            if (ret == NO) {
                return ret;
            }
        }
	}	
	[fetchRequest release], fetchRequest = nil;
	
	ret = [self save:error];
	
	return ret;
}

@end
