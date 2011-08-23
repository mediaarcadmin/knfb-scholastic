//
//  SCHPictureStarterCanvasDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPictureStarterCanvas;

@protocol SCHPictureStarterCanvasDelegate <NSObject>

@required
- (void)canvas:(SCHPictureStarterCanvas *)canvas didReceiveTapAtPoint:(CGPoint)point;
- (void)canvas:(SCHPictureStarterCanvas *)canvas didBeginDragAtPoint:(CGPoint)point;
- (void)canvas:(SCHPictureStarterCanvas *)canvas didMoveDragAtPoint:(CGPoint)point;
- (void)canvas:(SCHPictureStarterCanvas *)canvas didEndDragAtPoint:(CGPoint)point;

@end
