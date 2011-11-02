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

@interface SCHStoryInteractionControllerScratchAndSee : SCHStoryInteractionController <SCHStoryInteractionScratchViewDelegate>

@property (nonatomic, retain) IBOutlet SCHStoryInteractionScratchView *scratchView;
@property (nonatomic, retain) IBOutlet UIView *buttonContainerView;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *answerButtons;
@property (nonatomic, retain) IBOutlet UIImageView *progressImageView;
@property (nonatomic, retain) IBOutlet UIImageView *progressCoverImageView;
@property (nonatomic, retain) IBOutlet UIView *progressView;

@property (nonatomic, retain) IBOutlet UILabel *aLabel;
@property (nonatomic, retain) IBOutlet UILabel *bLabel;
@property (nonatomic, retain) IBOutlet UILabel *cLabel;

- (IBAction)questionButtonTouched:(UIButton *)sender;
- (IBAction)questionButtonTapped:(UIButton *)sender;

@end
