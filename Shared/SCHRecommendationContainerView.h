//
//  SCHRecommendationContainerView.h
//  Scholastic
//
//  Created by Matt Farrugia on 06/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHRecommendationListView.h"
#import "SCHRecommendationViewDelegate.h"

@interface SCHRecommendationContainerView : UIView <SCHRecommendationViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *container;
@property (nonatomic, retain) IBOutlet UIView *box;
@property (nonatomic, retain) IBOutlet UILabel *subtitle;
@property (nonatomic, retain) IBOutlet UILabel *heading;
@property (nonatomic, retain) IBOutlet UILabel *fetchingLabel;
@property (nonatomic, assign) id<SCHRecommendationListViewDelegate> listViewDelegate;
@property (nonatomic, assign) NSUInteger maxRecommendations;

@end
