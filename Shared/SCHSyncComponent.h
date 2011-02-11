//
//  SCHSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHComponent.h"
#import "NSNumber+ObjectTypes.h"

@interface SCHSyncComponent : SCHComponent
{

}

@property (assign, nonatomic) BOOL isSynchronizing;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

- (BOOL)synchronize;

@end
