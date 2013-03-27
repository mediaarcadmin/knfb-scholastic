//
//  SCHDictionaryManifestEntry.h
//  Scholastic
//
//  Created by John S. Eddie on 22/03/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHAppDictionaryManifestEntry;

typedef enum {
    SCHDictionaryCategoryProcessingStateNeedsProcessing = 0,
	SCHDictionaryCategoryProcessingStateReady,
} SCHDictionaryCategoryProcessingState;


@interface SCHDictionaryManifestEntry : NSObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, assign) BOOL firstManifestEntry;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) SCHDictionaryCategoryProcessingState state;
@property (nonatomic, retain) NSString *toVersion;
@property (nonatomic, retain) NSString *url;

- (id)initWithAppDictionaryManifestEntry:(SCHAppDictionaryManifestEntry *)appDictionaryManifestEntry;

@end
