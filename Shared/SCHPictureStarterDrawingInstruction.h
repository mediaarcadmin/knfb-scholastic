//
//  SCHPictureStarterDrawingInstruction.h
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHPictureStarterDrawingInstruction <NSObject>

- (void)setScale:(CGFloat)scale;
- (void)updatePosition:(CGPoint)point;
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;
- (BOOL)shouldCommitInstantly;

@end

@interface SCHPictureStarterLineDrawingInstruction : NSObject <SCHPictureStarterDrawingInstruction>
@property (nonatomic, assign) CGPoint *points;
@property (nonatomic, assign) NSInteger pointCount;
@property (nonatomic, assign) NSInteger pointCapacity;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;
- (CGBlendMode)blendMode;
@end

@interface SCHPictureStarterEraseDrawingInstruction : SCHPictureStarterLineDrawingInstruction
@end

@interface SCHPictureStarterStickerDrawingInstruction : NSObject <SCHPictureStarterDrawingInstruction>
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, retain) UIImage *sticker;
@property (nonatomic, assign) CGFloat scale;
@end
