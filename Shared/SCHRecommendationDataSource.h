//
//  SCHRecommendationDataSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHRecommendationViewDataSource;

@protocol SCHRecommendationDataSource <NSObject>

@required
- (BOOL)shouldShowRecommendationView;

@optional
- (id <SCHRecommendationViewDataSource>)recommendationViewDataSource;
- (void)setRecommendationViewDataSource:(id <SCHRecommendationViewDataSource>)recommendationViewDataSource;
- (Class)pageContentsViewSpiritSuperClass;

@end