//
//  SCHUserContentItemMigration.m
//  Scholastic
//
//  Created by John Eddie on 13/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHUserContentItemMigration.h"

@implementation SCHUserContentItemMigration

- (BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sInstance 
                                      entityMapping:(NSEntityMapping *)mapping 
                                            manager:(NSMigrationManager *)manager 
                                              error:(NSError **)error
{
    // copy Version to new attrribute LastVersion
    switch ([[[mapping userInfo] valueForKey:@"modelVersion"] integerValue]) {
        case 1:
        {
            NSString *version = [sInstance valueForKey:@"Version"];
            
            for (NSPropertyMapping *currentMapping in [mapping attributeMappings]) {
                if( [[currentMapping name] isEqualToString:@"LastVersion"] ) {
                    [currentMapping setValueExpression:[NSExpression expressionForConstantValue:version]];
                    break;
                }            
            }        
            break;
        }
            
        default:
            break;
    }
    
	return [super createDestinationInstancesForSourceInstance:sInstance 
                                                entityMapping:mapping 
                                                      manager:manager 
                                                        error:error];
}

@end
