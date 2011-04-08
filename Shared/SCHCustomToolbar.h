//
//  SCHCustomNavigationBar.h
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
// code adapted from 

#import <Foundation/Foundation.h>


@interface SCHCustomToolbar : UIToolbar {
    
}

@property (nonatomic, retain) UIImageView *barBackgroundImage;

-(void) setBackgroundWith:(UIImage*)backgroundImage;
-(void) clearBackground;

@end
