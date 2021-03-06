//
//  SCHPictureStarterColorChooser.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHPictureStarterColorChooser : UIControl

@property (nonatomic, assign) NSInteger selectedColorIndex;
@property (nonatomic, readonly) UIColor *selectedColor;

- (BOOL)selectionIsEraser;
- (void)clearSelection;

@end
