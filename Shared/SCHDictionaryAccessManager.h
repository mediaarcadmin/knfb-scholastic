//
//  SCHDictionaryAccessManager.h
//  Scholastic
//
//  Created by Gordon Christie on 25/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSCHDictionaryYoungReader = @"YD";
static NSString* const kSCHDictionaryOlderReader = @"OD";


@interface SCHDictionaryAccessManager : NSObject {
    
}

@property dispatch_queue_t dictionaryAccessQueue;

// TODO: clean up threading and MOC access
@property (nonatomic, assign) NSManagedObjectContext *managedObjectContextForCurrentThread;

+ (SCHDictionaryAccessManager *) sharedAccessManager;

- (void) updateOnReady;

// HTML definition for a word (uses YD/OD as category)
- (NSString *) HTMLForWord: (NSString *) dictionaryWord category: (NSString *) category;

// speak a word for a category
- (void) speakWord: (NSString *) dictionaryWord category: (NSString *) category;

// speak a word definition
- (void) speakYoungerWordDefinition: (NSString *) dictionaryWord;

// stop all speaking
- (void) stopAllSpeaking;


@end
