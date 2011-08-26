//
//  SCHPictureStarterStickerChooserDataSource.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPictureStarterStickerChooser;
@class SCHPictureStarterStickerChooserThumbnailView;

@protocol SCHPictureStarterStickerChooserDataSource <NSObject>

@required
- (NSInteger)numberOfStickersForChooserIndex:(NSInteger)chooser;
- (UIImage *)imageAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser;

- (void)thumbnailAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooserIndex result:(void(^)(UIImage *thumb))resultBlock;

@end
