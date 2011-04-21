//
//  SCHCustomNavigationBar.h
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
// code adapted from 

#import <Foundation/Foundation.h>


@interface SCHCustomNavigationBar : UINavigationBar {
    
}

@property (nonatomic, retain) UIImage *backgroundImage;

- (void)setTheme:(NSString *)newImageKey;

@end
