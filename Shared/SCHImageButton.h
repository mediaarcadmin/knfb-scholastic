//
//  SCHImageButton.h
//  Scholastic
//
//  Created by John S. Eddie on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHImageButton;

typedef void (^ActionBlock)(SCHImageButton *imageButton);

@interface SCHImageButton : UIImageView 
{    
}

@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) ActionBlock actionBlock;

@end
