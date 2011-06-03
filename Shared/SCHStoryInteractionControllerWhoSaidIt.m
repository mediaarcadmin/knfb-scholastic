//
//  SCHStoryInteractionControllerWhoSaidIt.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerWhoSaidIt.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"
#import "SCHStoryInteractionWhoSaidIt.h"

@interface SCHStoryInteractionControllerWhoSaidIt ()

@property (nonatomic, retain) NSArray *statementLabels;
@property (nonatomic, retain) NSArray *sources;
@property (nonatomic, retain) NSArray *targets;

@end

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
@synthesize statementLabels;
@synthesize sources;
@synthesize targets;

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
    [statementLabels release];
    [sources release];
    [targets release];
    [super dealloc];
}

- (void)setupView
{
    self.statementLabels = [NSArray arrayWithObjects:self.statementLabel1, self.statementLabel2, self.statementLabel3, self.statementLabel4, self.statementLabel5, nil];
    self.sources = [NSArray arrayWithObjects:self.source1, self.source2, self.source3, self.source4, self.source5, self.source6, nil];
    self.targets = [NSArray arrayWithObjects:self.target1, self.target2, self.target3, self.target4, self.target5, nil];

    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)[self storyInteraction];
    NSInteger i = 0;
    for (UILabel *label in self.statementLabels) {
        if (i == whoSaidIt.distracterIndex) {
            i++;
        }
        label.tag = i;
        label.text = [[whoSaidIt.statements objectAtIndex:i] text];
        i++;
    }
    
    i = 0;
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        source.title = [[whoSaidIt.statements objectAtIndex:i] source];
        source.tag = i;
        [source setDragTargets:self.targets];
        i++;
    }
}

@end
