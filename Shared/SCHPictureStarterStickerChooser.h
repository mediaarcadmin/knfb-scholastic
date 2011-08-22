//
//  SCHPictureStarterStampChooser.h
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHPictureStarterStickerChooserDataSource;
@protocol SCHPictureStarterStickerChooserDelegate;

@interface SCHPictureStarterStickerChooser : UITableView <UITableViewDataSource, UITableViewDelegate> {}

@property (nonatomic, assign) NSInteger chooserIndex;
@property (nonatomic, assign) id<SCHPictureStarterStickerChooserDataSource> stickerDataSource;
@property (nonatomic, assign) id<SCHPictureStarterStickerChooserDelegate> stickerDelegate;

- (void)clearSelection;

@end
