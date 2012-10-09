//
//  SCHProfileTooltip.h
//  Scholastic
//
//  Created by Gordon Christie on 08/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHProfileTooltipDelegate;

@interface SCHProfileTooltip : UIView

@property (nonatomic, assign) id <SCHProfileTooltipDelegate> delegate;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, assign) BOOL usesCloseButton;

- (void)setTitle:(NSString *)title bodyText:(NSString *)bodyText;
- (void)setFirstTitle:(NSString *)title firstBodyText:(NSString *)bodyText secondTitle:(NSString *)secondTitle secondBodyText:(NSString *)secondBodyText;


@end

@protocol SCHProfileTooltipDelegate <NSObject>

- (void)profileTooltipPressedClose:(SCHProfileTooltip *)tooltip;

@end