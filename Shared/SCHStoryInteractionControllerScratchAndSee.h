//
//  SCHStoryInteractionControllerScratchAndSee.h
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"


@interface SCHStoryInteractionControllerScratchAndSee : SCHStoryInteractionController {
    
    UIImageView *pictureView;
    UIView *scratchView;
}

@property (nonatomic, retain) IBOutlet UIView *scratchView;
@property (nonatomic, retain) IBOutlet UIImageView *pictureView;
@property (nonatomic, retain) IBOutlet UIButton *answerButton1;
@property (nonatomic, retain) IBOutlet UIButton *answerButton2;
@property (nonatomic, retain) IBOutlet UIButton *answerButton3;

- (IBAction)questionButtonTapped:(id)sender;

@end
