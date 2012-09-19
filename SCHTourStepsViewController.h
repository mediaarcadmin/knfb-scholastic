//
//  SCHTourStepsViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 18/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SCHTourStepsViewTypeSingleImage = 0,
    SCHTourStepsViewTypeDoubleImage,
    SCHTourStepsViewTypeReadthrough
} SCHTourStepsViewType;

@interface SCHTourStepsViewController : UIViewController <UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@end
