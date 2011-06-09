//
//  SCHStoryInteractionDraggableTargetView.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHStoryInteractionDraggableTargetView : UIImageView {}

@property (nonatomic, assign) NSInteger matchTag;
@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, assign) BOOL occupied;

- (CGPoint)targetCenterInView:(UIView *)view;

@end
