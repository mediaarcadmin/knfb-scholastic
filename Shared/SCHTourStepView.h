//
//  SCHTourStepView.h
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHTourStepViewDelegate;

@interface SCHTourStepView : UIView

@property (nonatomic, assign) id <SCHTourStepViewDelegate> delegate;
@property (nonatomic, assign) NSString *buttonTitle;

@end


@protocol SCHTourStepViewDelegate <NSObject>

- (void)tourStepPressedButton:(SCHTourStepView *)tourStepView;

@end