//
//  SCHStretchableImageButton.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHStretchableImageButton : UIButton

// default value of 0 means the left cap is calculated from the image size
@property (nonatomic, assign) NSInteger customLeftCap;

// default value of 0 means the top cap is calculated from the image size
@property (nonatomic, assign) NSInteger customTopCap;

@end
