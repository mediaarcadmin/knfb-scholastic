//
//  SCHCoreDataOperation.h
//  Scholastic
//
//  Created by Neil Gall on 29/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHCoreDataOperation : NSOperation {}

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;

@end
