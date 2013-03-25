//
//  SCHAppDictionaryManifestEntry.h
//  Scholastic
//
//  Created by Neil Gall on 26/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHAppDictionaryManifestEntry;

@class SCHAppDictionaryState;

@interface SCHAppDictionaryManifestEntry : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSString * toVersion;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) SCHAppDictionaryState *appDictionaryState;

@end
