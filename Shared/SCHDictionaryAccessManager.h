//
//  SCHDictionaryAccessManager.h
//  Scholastic
//
//  Created by Gordon Christie on 25/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString* const kSCHDictionaryYoungReader;
extern NSString* const kSCHDictionaryOlderReader;

@interface SCHDictionaryAccessManager : NSObject
{    
}

@property dispatch_queue_t dictionaryAccessQueue;

@property (nonatomic, retain) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SCHDictionaryAccessManager *)sharedAccessManager;

- (void)fetchCSSFromDisk;

// HTML definition for a word (uses YD/OD as category)
- (NSString *)HTMLForWord:(NSString *)dictionaryWord category:(NSString *)category;

// speak a word for a category
- (void)speakWord:(NSString *)dictionaryWord category:(NSString *)category;

// speak a word definition
- (void)speakYoungerWordDefinition:(NSString *)dictionaryWord;

// stop all speaking
- (void)stopAllSpeaking;

// does the dictionary have a definition for the word in question?
- (BOOL)dictionaryContainsWord:(NSString *)word forCategory:(NSString*)category;

@end
