//
//  SCHDictionaryManager.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDictionary.h"


@interface SCHDictionaryManager : NSObject {

}

+ (SCHDictionaryManager *) sharedDictionaryManager;
- (SCHDictionary *) dictionaryObject;

@end
