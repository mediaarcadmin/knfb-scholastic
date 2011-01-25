//
//  SCHWebServiceSync.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "BITAPIProxyDelegate.h"

@class SCHLibreAccessWebService;

@interface SCHWebServiceSync : NSObject <BITAPIProxyDelegate> {
	
}

@property (retain, nonatomic) SCHLibreAccessWebService *libreAccessWebService;	

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;	

- (void)update;

@end
