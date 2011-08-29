//
//  SCHPictureStarterStickerChooserThumbnailView.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterStickerChooserThumbnailView.h"

enum {
    kSelectionStrokeWidth = 4
};

@implementation SCHPictureStarterStickerChooserThumbnailView

@synthesize selected;
@synthesize stickerTag;

- (void)setSelected:(BOOL)newSelected
{
    selected = newSelected;

    self.layer.borderWidth = selected ? kSelectionStrokeWidth : 0;
    self.layer.borderColor = [[UIColor colorWithRed:0 green:1 blue:0 alpha:1] CGColor];
}

@end
