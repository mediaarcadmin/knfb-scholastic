//
//  SCHAppState.h
//  Scholastic
//
//  Created by John S. Eddie on 09/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHAppState;

extern NSString * const kSCHAppStatefetchAppState;

@interface SCHAppState : NSManagedObject 
{
}

@property (nonatomic, retain) NSNumber * ShouldSync;
@property (nonatomic, retain) NSNumber * ShouldAuthenticate;
@property (nonatomic, retain) NSNumber * DataStoreType;
@property (nonatomic, retain) NSNumber * ShouldSyncNotes;
@property (nonatomic, retain) NSString * LastKnownAuthToken;
@property (nonatomic, retain) NSNumber * ServerDateDelta;

@end
