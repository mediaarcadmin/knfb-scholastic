//
//  SCHAnnotationSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

// Constants
extern NSString * const SCHAnnotationSyncComponentDidCompleteNotification;
extern NSString * const SCHAnnotationSyncComponentDidFailNotification;
extern NSString * const SCHAnnotationSyncComponentProfileIDs;

@interface SCHAnnotationSyncComponent : SCHSyncComponent 

@property (atomic, retain) NSMutableArray *savedAnnotations;
@property (atomic, retain) NSDate *lastSyncSaveCalled;

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books;
- (void)removeProfile:(NSNumber *)profileID withBooks:(NSArray *)books;
- (BOOL)haveProfiles;
- (BOOL)nextProfile;

- (BOOL)annotationIDIsValid:(NSNumber *)annotationID;
- (BOOL)requestListProfileContentAnnotationsForProfileID:(NSNumber *)profileID;
- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID 
                                   usingMethod:(NSString *)method
                                      userInfo:(NSDictionary *)userInfo;


@end
