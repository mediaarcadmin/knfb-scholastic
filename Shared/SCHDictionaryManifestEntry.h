//
//  SCHDictionaryManifestEntry.h
//  Scholastic
//
//  Created by John S. Eddie on 22/03/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SCHDictionaryCategoryProcessingStateError = 0,
    SCHDictionaryCategoryProcessingStateDownloadError,
    SCHDictionaryCategoryProcessingStateUnableToOpenZipError,
    SCHDictionaryCategoryProcessingStateUnZipFailureError,
    SCHDictionaryCategoryProcessingStateParseError,

	SCHDictionaryCategoryProcessingStateNeedsDownload,
	SCHDictionaryCategoryProcessingStateNeedsUnzip,
	SCHDictionaryCategoryProcessingStateNeedsParse,
	SCHDictionaryCategoryProcessingStateReady,
} SCHDictionaryCategoryProcessingState;


@interface SCHDictionaryManifestEntry : NSObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) SCHDictionaryCategoryProcessingState state;
@property (nonatomic, retain) NSString *toVersion;
@property (nonatomic, retain) NSString *url;


@end
