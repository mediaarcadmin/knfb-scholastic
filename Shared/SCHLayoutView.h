//
//  SCHLayoutView.h
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHReadingView.h"
#import <libEucalyptus/EucIndexBasedPageTurningView.h>

@interface SCHLayoutView : SCHReadingView <EucPageTurningViewDelegate, EucIndexBasedPageTurningViewDataSource> {
    
}

- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex;

// animate a zoom out to current page and invoke completion when done
- (void)zoomOutToCurrentPageWithCompletionHandler:(dispatch_block_t)completion;

@end
