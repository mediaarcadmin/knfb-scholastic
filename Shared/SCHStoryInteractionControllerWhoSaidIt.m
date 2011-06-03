//
//  SCHStoryInteractionControllerWhoSaidIt.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerWhoSaidIt.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

@implementation SCHStoryInteractionControllerWhoSaidIt

@synthesize statementLabel1;
@synthesize statementLabel2;
@synthesize statementLabel3;
@synthesize statementLabel4;
@synthesize statementLabel5;
@synthesize source1;
@synthesize source2;
@synthesize source3;
@synthesize source4;
@synthesize source5;
@synthesize source6;
@synthesize target1;
@synthesize target2;
@synthesize target3;
@synthesize target4;
@synthesize target5;
@synthesize checkAnswersButton;

- (void)dealloc
{
    [statementLabel1 release];
    [statementLabel2 release];
    [statementLabel3 release];
    [statementLabel4 release];
    [statementLabel5 release];
    [source1 release];
    [source2 release];
    [source3 release];
    [source4 release];
    [source5 release];
    [source6 release];
    [target1 release];
    [target2 release];
    [target3 release];
    [target4 release];
    [target5 release];
    [checkAnswersButton release];
    [super dealloc];
}

@end
