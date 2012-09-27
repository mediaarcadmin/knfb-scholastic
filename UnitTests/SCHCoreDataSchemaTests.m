//
//  SCHCoreDataSchemaTests.m
//  Scholastic
//
//  Created by John S. Eddie on 13/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHCoreDataSchemaTests.h"

@implementation SCHCoreDataSchemaTests

- (void)testWebServiceEntitiesShouldBeOptional
{
    NSURL *modelURL = [[NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"] URLForResource:@"Scholastic" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] autorelease];
    NSEntityDescription *entityDescription = nil;

    NSDictionary *entitiesByName = managedObjectModel.entitiesByName;
    for (NSString *entityName in [entitiesByName allKeys]) {
        if ([self isWebServiceEntity:entityName] == YES) {
            entityDescription = [entitiesByName objectForKey:entityName];
            for (NSAttributeDescription *attributeDescription in [entityDescription.attributesByName allValues]) {
                STAssertTrue(attributeDescription.isOptional, @"%@:%@ should be optional as it's a web service entity", entityName, attributeDescription.name);
            }
        }
    }
}

- (BOOL)isWebServiceEntity:(NSString *)name
{
    // SCHApp entities are local to the app and not used by web services
    return [name hasPrefix:@"SCHApp"] == NO;
}

@end
