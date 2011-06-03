//
//  SCHStoryInteractionControllerMultipleChoiceText.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerMultipleChoiceText.h"


@implementation SCHStoryInteractionControllerMultipleChoiceText

@synthesize promptLabel;
@synthesize answerButton1;
@synthesize answerButton2;
@synthesize answerButton3;
@synthesize closeButton;
@synthesize playAudioButton;

- (void)dealloc
{
    [promptLabel release];
    [answerButton1 release];
    [answerButton2 release];
    [answerButton3 release];
    [closeButton release];
    [playAudioButton release];
    [super dealloc];
}

- (IBAction)answerButtonTapped:(id)sender
{
    
}

- (IBAction)closeButtonTapped:(id)sender
{
    
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    
}

@end
