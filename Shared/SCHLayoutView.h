//
//  SCHLayoutView.h
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHReadingView.h"
#import <libEucalyptus/EucPageTurningView.h>

@interface SCHLayoutView : SCHReadingView <EucPageTurningViewDelegate, EucPageTurningViewBitmapDataSource> {
    
}

@end
