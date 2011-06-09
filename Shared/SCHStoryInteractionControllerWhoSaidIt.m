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

#define kSourceLabelTag 1001
#define kSourceImageTag 1002
#define kSnapDistanceSq 900
#define kSourceOffsetY_iPad 6
#define kSourceOffsetY_iPhone 3
#define kTargetOffsetX_iPad -12
#define kTargetOffsetX_iPhone -7

@implementation SCHStoryInteractionControllerWhoSaidIt

@synthesize checkAnswersButton;
@synthesize statementLabels;
@synthesize sources;
@synthesize targets;

- (void)dealloc
{
    [checkAnswersButton release];
    [statementLabels release];
    [sources release];
    [targets release];
    [super dealloc];
}

- (void)setupView
{
    CGPoint targetCenterOffset, sourceCenterOffset;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        targetCenterOffset = CGPointMake(kTargetOffsetX_iPad, 0);
        sourceCenterOffset = CGPointMake(0, kSourceOffsetY_iPad);
    } else {
        targetCenterOffset = CGPointMake(kTargetOffsetX_iPhone, 0);
        sourceCenterOffset = CGPointMake(0, kSourceOffsetY_iPhone);
    }
    
    // set up the labels and tag the targets with the correct indices
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)[self storyInteraction];
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionWhoSaidItStatement *statement in whoSaidIt.statements) {
        if (statement.questionIndex != whoSaidIt.distracterIndex) {
            [[self.statementLabels objectAtIndex:targetIndex] setText:statement.text];
            SCHStoryInteractionDraggableTargetView *target = [self.targets objectAtIndex:targetIndex];
            target.matchTag = statement.questionIndex;
            target.centerOffset = targetCenterOffset;
            targetIndex++;
        }
    }

    // jumble up the sources and tag with the correct indices
    NSMutableArray *statements = [whoSaidIt.statements mutableCopy];
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        int index = arc4random() % [statements count];
        SCHStoryInteractionWhoSaidItStatement *statement = [statements objectAtIndex:index];
        UILabel *label = (UILabel *)[source viewWithTag:kSourceLabelTag];
        label.text = statement.source;
        source.matchTag = statement.questionIndex;
        source.centerOffset = sourceCenterOffset;
        source.snapDistanceSq = kSnapDistanceSq;
        [source setDragTargets:self.targets];
        [statements removeObjectAtIndex:index];
    }
    [statements release];
}

- (void)checkAnswers:(id)sender
{
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        SCHStoryInteractionDraggableTargetView *target = source.attachedTarget;
        if (!target) {
            continue;
        }
        NSString *root = (source.matchTag == target.matchTag ? @"storyinteraction-draggable-green-" : @"storyinteraction-draggable-red-");
        UIImage *image = [UIImage imageNamed:[root stringByAppendingString:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone"]];
        UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
        imageView.highlightedImage = image;
        [imageView setHighlighted:YES];
    }

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        for (SCHStoryInteractionDraggableView *source in self.sources) {
            UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
            [imageView setHighlighted:NO];
        }
    });
}

@end
