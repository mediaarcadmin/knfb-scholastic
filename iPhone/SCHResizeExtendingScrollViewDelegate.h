//
//  SCHResizeExtendingScrollViewDelegate.h
//  Scholastic
//
//  Created by John S. Eddie on 08/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHResizeExtendingScrollView;

@protocol SCHResizeExtendingScrollViewDelegate

- (void)resizeExtendingScrollViewDidLayoutSubviews:(SCHResizeExtendingScrollView *)resizeExtendingScrollView;

@end