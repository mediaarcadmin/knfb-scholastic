//
//  SCHRecommendationViewDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 23/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHRecommendationViewDelegate <NSObject>

@required
- (void)updateWithRecommendationDictionaries:(NSArray *)recommendationDictionaries wishListDictionaries:(NSArray *)wishlistDictionaries;

@end
