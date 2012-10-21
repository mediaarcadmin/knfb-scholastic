//
//  SCHRecommendationBatchOperation.h
//  Scholastic
//
//  Created by Matt Farrugia on 20/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationOperation.h"

@interface SCHRecommendationBatchOperation : SCHRecommendationOperation

@property (nonatomic, copy) NSArray* isbns;

@end