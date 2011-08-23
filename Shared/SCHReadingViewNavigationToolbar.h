//
//  SCHReadingViewNavigationToolbar.h
//  Scholastic
//
//  Created by Matt Farrugia on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	kSCHReadingViewNavigationToolbarStyleYoungerPhone = 0,
    kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone,
	kSCHReadingViewNavigationToolbarStyleOlderPhone,
	kSCHReadingViewNavigationToolbarStyleYoungerPad,
    kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad,
    kSCHReadingViewNavigationToolbarStyleOlderPad
} SCHReadingViewNavigationToolbarStyle;

@protocol SCHReadingViewNavigationToolbarDelegate <NSObject>

@optional

- (void)backAction:(id)sender;
- (void)pictureStarterAction:(id)sender;
- (void)audioAction:(id)sender;
- (void)helpAction:(id)sender;

@end

@interface SCHReadingViewNavigationToolbar : UIView {
    
}

@property (nonatomic, assign) id <SCHReadingViewNavigationToolbarDelegate> delegate;

- (id)initWithStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation;

- (void)setTitle:(NSString *)title;
- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end
