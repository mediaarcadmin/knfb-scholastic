//
//  SCHThemeImageView.h
//  Scholastic
//
//  Created by John S. Eddie on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHThemeImageView : UIImageView 
{    
}

- (void)setTheme:(NSString *)newImageKey;
- (void)updateTheme:(UIInterfaceOrientation)orientation;

@end
