//
//  SCHPictureStarterStickerChooserDataSource.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPictureStarterStickerChooser;

@protocol SCHPictureStarterStickerChooserDataSource <NSObject>

@required
- (NSInteger)numberOfStickersForChooserIndex:(NSInteger)chooser;
- (UIImage *)thumbnailAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser;
- (UIImage *)imageAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser;

@end
