//
//  SCHProfileTooltipContainer.h
//  Scholastic
//
//  Created by Gordon Christie on 09/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileTooltip.h"

@protocol SCHProfileTooltipContainerDelegate;

@interface SCHProfileTooltipContainer : UIView <SCHProfileTooltipDelegate>

@property (nonatomic, assign) id <SCHProfileTooltipContainerDelegate> delegate;

- (void)addHighlightAtLocation:(CGPoint)location;

@end


@protocol SCHProfileTooltipContainerDelegate <NSObject>

- (void)profileTooltipContainerSelectedClose:(SCHProfileTooltipContainer *)container;

@end