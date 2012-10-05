//
//  SCHSettingsViewCell.m
//  Scholastic
//
//  Created by Matt Farrugia on 05/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHSettingsViewCell.h"

@implementation SCHSettingsViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect contentFrame = self.contentView.frame;
        contentFrame.origin.x += 32;
        contentFrame.size.width -= 64;
        contentFrame.size.height += 1;
        self.contentView.frame = contentFrame;
    }
}

@end
