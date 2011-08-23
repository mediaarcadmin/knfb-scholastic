//
//  SCHPictureStarterCanvasDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPictureStarterCanvas;
@protocol SCHPictureStarterDrawingInstruction;

@protocol SCHPictureStarterCanvasDelegate <NSObject>

@required
- (id<SCHPictureStarterDrawingInstruction>)drawingInstruction;

@end
