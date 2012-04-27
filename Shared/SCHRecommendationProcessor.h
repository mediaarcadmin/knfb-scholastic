//
//  SCHRecommendationProcessor.h
//  Scholastic
//
//  Created by John Eddie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHRecommendationProcessor : NSObject

- (NSArray *)recommendationsFrom:(NSData *)recommendationXML;

@end