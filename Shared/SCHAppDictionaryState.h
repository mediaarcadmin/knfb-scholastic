//
//  SCHAppDictionaryState.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHAppDictionaryState;

@class SCHAppDictionaryManifestEntry;

@interface SCHAppDictionaryState : NSManagedObject {

}

@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSNumber * remainingFileSize;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSSet *appDictionaryManifestEntry;

- (SCHAppDictionaryManifestEntry *)appDictionaryManifestEntryForDictionaryCategory:(NSString *)dictionaryCategory;

@end

@interface SCHAppDictionaryState (CoreDataGeneratedAccessors)

- (void)addAppDictionaryManifestEntryObject:(SCHAppDictionaryManifestEntry *)value;
- (void)removeAppDictionaryManifestEntryObject:(SCHAppDictionaryManifestEntry *)value;
- (void)addAppDictionaryManifestEntry:(NSSet *)values;
- (void)removeAppDictionaryManifestEntry:(NSSet *)values;

@end
