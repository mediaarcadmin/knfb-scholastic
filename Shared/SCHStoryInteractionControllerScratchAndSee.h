//
//  SCHStoryInteractionControllerScratchAndSee.h
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionScratchView.h"

@interface SCHStoryInteractionControllerScratchAndSee : SCHStoryInteractionController <SCHStoryInteractionScratchViewDelegate> {

}

@property (nonatomic, retain) IBOutlet SCHStoryInteractionScratchView *scratchView;
@property (nonatomic, retain) IBOutlet UIImageView *pictureView;
@property (nonatomic, retain) IBOutlet UIButton *answerButton1;
@property (nonatomic, retain) IBOutlet UIButton *answerButton2;
@property (nonatomic, retain) IBOutlet UIButton *answerButton3;

- (IBAction)questionButtonTapped:(UIButton *)sender;

@end
