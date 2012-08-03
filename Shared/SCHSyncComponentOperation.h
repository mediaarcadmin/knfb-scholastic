//
//  SCHSyncComponentOperation.h
//  Scholastic
//
//  Created by John Eddie on 14/06/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHSyncComponent;

@interface SCHSyncComponentOperation : NSOperation

@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;
@property (nonatomic, retain) SCHSyncComponent *syncComponent;
@property (nonatomic, retain) NSDictionary *result;
@property (nonatomic, retain) NSDictionary *userInfo;

- (id)initWithSyncComponent:(SCHSyncComponent *)aSyncComponent
                     result:(NSDictionary *)aResult
                   userInfo:(NSDictionary *)aUserInfo;
- (void)saveWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext;

- (id)makeNullNil:(id)object;

@end
