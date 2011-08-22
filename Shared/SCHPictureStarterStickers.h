//
//  SCHPictureStarterStickers.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHPictureStarterStickerChooserDataSource.h"

@interface SCHPictureStarterStickers : NSObject <SCHPictureStarterStickerChooserDataSource> {}

@property (nonatomic, assign) NSInteger numberOfChoosers;

@end
