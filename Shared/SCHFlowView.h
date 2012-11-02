//
//  BlioFlowView.h
//  BlioApp
//
//  Created by James Montgomerie on 04/01/2010.
//  Copyright 2010 Things Made Out Of Other Things. All rights reserved.
//

#import <libEucalyptus/EucBookView.h>
#import "SCHReadingView.h"

@protocol SCHRecommendationViewDataSource;

@interface SCHFlowView : SCHReadingView <EucBookViewDelegate> {

}

- (id)initWithFrame:(CGRect)frame
     bookIdentifier:(SCHBookIdentifier *)bookIdentifier
managedObjectContext:(NSManagedObjectContext *)managedObjectContext
           delegate:(id<SCHReadingViewDelegate>)delegate
              point:(SCHBookPoint *)point
recommendationViewDataSource:(id <SCHRecommendationViewDataSource>)recommendationViewDataSource;

@end
