//
//  NSManagedObjectContext+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 24/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSManagedObjectContext+Extensions.h"


@implementation NSManagedObjectContext (Extensions)

- (BOOL)BITemptyEntity:(NSString *)entityName error:(NSError **)error
{
	BOOL ret = NO;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self]];	
	
	NSArray *results = [self executeFetchRequest:fetchRequest error:error];
	for (NSManagedObject *managedObject in results) {
		[self deleteObject:managedObject];
	}	
	[fetchRequest release], fetchRequest = nil;
	
	ret = [self save:error];
	
	return(ret);
}

@end
