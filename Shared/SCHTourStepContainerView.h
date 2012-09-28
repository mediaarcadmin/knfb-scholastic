//
//  SCHTourStepContainerView.h
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHTourStepView.h"

@interface SCHTourStepContainerView : UIView

@property (nonatomic, retain) NSString *containerTitleText;
@property (nonatomic, retain) NSString *containerSubtitleText;

@property (nonatomic, retain) SCHTourStepView *mainTourStepView;
@property (nonatomic, retain) SCHTourStepView *secondTourStepView;

- (void)layoutForCurrentTourStepViews;

@end
