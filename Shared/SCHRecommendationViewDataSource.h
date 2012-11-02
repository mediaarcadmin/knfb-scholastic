//
//  SCHRecommendationViewDataSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHRecommendationViewDelegate;

@protocol SCHRecommendationViewDataSource <NSObject>

@required
- (BOOL)shouldShowRecommendationView;
- (UIView <SCHRecommendationViewDelegate> *)recommendationView;

@end
