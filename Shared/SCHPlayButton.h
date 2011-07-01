//
//  SCHPlayButton.h
//  Scholastic
//
//  Created by John S. Eddie on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHPlayButton;

typedef enum {
    SCHPlayButtonIconNone,
	SCHPlayButtonIconPlay,
    SCHPlayButtonIconPause
} SCHPlayButtonIcon;

typedef void (^PlayButtonActionBlock)(SCHPlayButton *playButton);

@interface SCHPlayButton : UIImageView 
{    
}

@property (nonatomic, assign) BOOL play;
@property (nonatomic, assign) SCHPlayButtonIcon icon;
@property (nonatomic, copy) PlayButtonActionBlock actionBlock;

@end
