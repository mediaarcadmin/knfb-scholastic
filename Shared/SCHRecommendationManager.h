//
//  SCHRecommendationManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

typedef enum {
    SCHRecommendationProcessingStateURLsNotPopulated           = -6,
    SCHRecommendationProcessingStateDownloadFailed             = -5,
    SCHRecommendationProcessingStateUnableToAcquireLicense     = -4,
    SCHRecommendationProcessingStateCachedCoverError           = -3,
	SCHRecommendationProcessingStateError                      = -2,
	SCHRecommendationProcessingStateBookVersionNotSupported    = -1,
	SCHRecommendationProcessingStateNoURLs                     = 0,
	SCHRecommendationProcessingStateNoCoverImage               = 1,
	SCHRecommendationProcessingStateReadyForBookFileDownload   = 2,
	SCHRecommendationProcessingStateDownloadStarted            = 3,
	SCHRecommendationProcessingStateDownloadPaused             = 4,
	SCHRecommendationProcessingStateReadyForLicenseAcquisition = 5,
	SCHRecommendationProcessingStateReadyForRightsParsing      = 6,
	SCHRecommendationProcessingStateReadyForAudioInfoParsing   = 7,
	SCHRecommendationProcessingStateReadyForTextFlowPreParse   = 8,
    SCHRecommendationProcessingStateReadyForSmartZoomPreParse  = 9,
	SCHRecommendationProcessingStateReadyForPagination         = 10,
	SCHRecommendationProcessingStateReadyToRead                = 11,
} SCHRecommendationProcessingState;

@interface SCHRecommendationManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+ (SCHRecommendationManager *)sharedProcessingManager;
- (void)cancelAllOperations;

@end