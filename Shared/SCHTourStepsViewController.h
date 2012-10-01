//
//  SCHTourStepsViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 18/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"
#import "SCHHitTestExtendingView.h"
#import "SCHTourStepContainerView.h"

typedef enum {
    SCHTourStepsViewTypeSingleImage = 0,
    SCHTourStepsViewTypeDoubleImage,
    SCHTourStepsViewTypeReadthrough,
    SCHTourStepsViewTypeBeginTour
} SCHTourStepsViewType;

@interface SCHTourStepsViewController : UIViewController <UIScrollViewDelegate, SCHTourStepContainerViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) DDPageControl *pageControl;
@property (retain, nonatomic) IBOutlet SCHHitTestExtendingView *forwardingView;

@end
