//
//  SCHDummyRecommendationOperations.m
//  Scholastic
//
//  Created by Gordon Christie on 04/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "QHTTPOperation.h"

@interface SCHRecommendationOperation : NSOperation

@end

//@interface QHTTPOperation : NSOperation
//
//@end
//
//@protocol QHTTPOperationDelegate <NSObject>
//@required
//- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize;
//- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize;
//- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error;
//@end

// reeclaration of interface
@interface SCHRecommendationDownloadCoverOperation : SCHRecommendationOperation <QHTTPOperationDelegate>

@end

@implementation SCHRecommendationOperation

@end
//
//@implementation QHTTPOperation
//
//@end

@interface SCHRecommendationManager : NSObject

@end

@implementation SCHRecommendationManager


@end

@interface BITNetworkActivityManager : NSObject

@end

@implementation BITNetworkActivityManager



@end