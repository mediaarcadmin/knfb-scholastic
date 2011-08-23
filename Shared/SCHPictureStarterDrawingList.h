//
//  SCHPictureStarterDrawingList.h
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHPictureStarterDrawingList : NSObject

- (void)addPoint:(CGPoint)point color:(UIColor *)color size:(NSInteger)size;
- (void)addLineFrom:(CGPoint)start to:(CGPoint)end color:(UIColor *)color size:(NSInteger)size;
- (void)addSticker:(UIImage *)sticker atPoint:(CGPoint)point;
- (void)clear;

- (void)drawInContext:(CGContextRef)context;

@end
