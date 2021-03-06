//
//  NSManagedObjectContext+Extensions.h
//  Scholastic
//
//  Created by John S. Eddie on 24/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extensions)

typedef void (^BITemptyEntityPriorToDeletionBlock)(NSManagedObject *managedObject);

- (BOOL)BITemptyEntity:(NSString *)entityName error:(NSError **)error 
  priorToDeletionBlock:(BITemptyEntityPriorToDeletionBlock)priorToDeletionBlock;

@end
