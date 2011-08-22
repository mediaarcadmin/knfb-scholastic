//
//  SCHStoryInteractionControllerPictureStarter.h
//  Scholastic
//
//  Created by Neil Gall on 19/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarter.h"

@interface SCHStoryInteractionControllerPictureStarterCustom : SCHStoryInteractionControllerPictureStarter

@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *backgroundChooserButtons;

- (IBAction)chooseBackground:(id)sender;

@end
