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
#import "UIView+SubviewOfClass.h"

#define kSnapDistanceSq 900
#define kSourceOffsetY_iPad 6
#define kSourceOffsetY_iPhone 3
#define kTargetOffsetX_iPad -12
#define kTargetOffsetX_iPhone -7

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
            target.tag = statement.questionIndex;
            target.centerOffset = targetCenterOffset;
            targetIndex++;
        }
    }

    // jumble up the sources and tag with the correct indices
    NSMutableArray *statements = [whoSaidIt.statements mutableCopy];
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        int index = arc4random() % [statements count];
        SCHStoryInteractionWhoSaidItStatement *statement = [statements objectAtIndex:index];
        UILabel *label = (UILabel *)[source subviewOfClass:[UILabel class]];
        label.text = statement.source;
        source.tag = statement.questionIndex;
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
        NSString *root = (source.tag == target.tag ? @"storyinteraction-draggable-green-" : @"storyinteraction-draggable-red-");
        UIImage *image = [UIImage imageNamed:[root stringByAppendingString:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone"]];
        UIImageView *imageView = (UIImageView *)[source subviewOfClass:[UIImageView class]];
        imageView.highlightedImage = image;
        [imageView setHighlighted:YES];
    }

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        for (SCHStoryInteractionDraggableView *source in self.sources) {
            UIImageView *imageView = (UIImageView *)[source subviewOfClass:[UIImageView class]];
            [imageView setHighlighted:NO];
        }
    });
}

@end
