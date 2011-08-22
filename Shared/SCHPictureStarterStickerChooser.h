//
//  SCHPictureStarterStampChooser.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHPictureStarterStickerChooserDataSource;

@interface SCHPictureStarterStickerChooser : UITableView <UITableViewDataSource> {}

@property (nonatomic, assign) NSInteger chooserIndex;
@property (nonatomic, assign) id<SCHPictureStarterStickerChooserDataSource> stickerDataSource;

@end
