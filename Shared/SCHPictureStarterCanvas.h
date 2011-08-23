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

- (void)setBackgroundImage:(UIImage *)backgroundImage;
- (void)paintAtPoint:(CGPoint)point color:(UIColor *)color size:(NSInteger)size;
- (void)paintLineFromPoint:(CGPoint)start toPoint:(CGPoint)end color:(UIColor *)color size:(NSInteger)size;
- (void)addSticker:(UIImage *)sticker atPoint:(CGPoint)point;

- (void)commit;

@end
