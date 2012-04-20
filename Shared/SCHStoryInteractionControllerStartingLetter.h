//
//  SCHStoryInteractionControllerStartingLetter.h
//  Scholastic
//
//  Created by John S. Eddie on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerStartingLetter : SCHStoryInteractionController 
{    
}

@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imageButtons;
@property (nonatomic, retain) IBOutlet UIView *buttonContainerView;

@end
