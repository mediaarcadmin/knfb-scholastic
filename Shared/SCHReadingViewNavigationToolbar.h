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
	kSCHReadingViewNavigationToolbarStyleOlderPhone,
	kSCHReadingViewNavigationToolbarStyleYoungerPad,
    kSCHReadingViewNavigationToolbarStyleOlderPad
} SCHReadingViewNavigationToolbarStyle;

@interface SCHReadingViewNavigationToolbar : UIView {
    
}

- (id)initWithStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation;

@end
