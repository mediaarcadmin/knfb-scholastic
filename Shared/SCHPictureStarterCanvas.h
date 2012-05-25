//
//  SCHPictureStarterCanvas.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHPictureStarterCanvasDelegate;

@interface SCHPictureStarterCanvas : UIView

@property (nonatomic, assign) id<SCHPictureStarterCanvasDelegate> delegate;

- (void)setDrawnImage:(UIImage *)drawnImage;
- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)clear;

- (CGImageRef)image;

@end
