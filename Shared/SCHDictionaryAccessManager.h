//
//  SCHDictionaryAccessManager.h
//  Scholastic
//
//  Created by Gordon Christie on 25/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHDictionaryAccessManager : NSObject {
    
}

@property dispatch_queue_t dictionaryAccessQueue;

+ (SCHDictionaryAccessManager *) sharedAccessManager;

// HTML definition for a word (uses YD/OD as category)
- (NSString *) HTMLForWord: (NSString *) dictionaryWord category: (NSString *) category;

@end
