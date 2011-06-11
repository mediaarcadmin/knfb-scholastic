//
//  SCHStoryInteractionControllerVideo.h
//  Scholastic
//
//  Created by John S. Eddie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHStoryInteractionController.h"

@class SCHPlayButton;

@interface SCHStoryInteractionControllerVideo : SCHStoryInteractionController
{    
}

@property (nonatomic, retain) IBOutlet UIView *movieContainerView;
@property (nonatomic, retain) IBOutlet SCHPlayButton *playButton;

@end
