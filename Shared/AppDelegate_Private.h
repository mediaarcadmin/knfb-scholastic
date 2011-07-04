//
//  AppDelegate_Private.h
//  Scholastic
//
//  Created by Neil Gall on 04/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate_Shared.h"

@interface AppDelegate_Shared (Private)

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@end
