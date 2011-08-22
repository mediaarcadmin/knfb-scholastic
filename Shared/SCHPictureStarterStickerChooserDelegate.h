//
//  SCHPictureStarterStickerChooserDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHPictureStarterStickerChooserDelegate <NSObject>

@required
- (void)stickerChooser:(NSInteger)chooserIndex choseImageAtIndex:(NSInteger)imageIndex;

@end
