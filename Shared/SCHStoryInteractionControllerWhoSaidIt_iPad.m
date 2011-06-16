//
//  SCHStoryInteractionControllerWhoSaidIt.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerWhoSaidIt_iPad.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"
#import "SCHStoryInteractionWhoSaidIt.h"
#import "NSArray+ViewSorting.h"

#define kSourceLabelTag 1001
#define kSourceImageTag 1002
#define kSnapDistanceSq 900
#define kSourceOffsetY_iPad 5
#define kSourceOffsetY_iPhone 3
#define kTargetOffsetX_iPad -13
#define kTargetOffsetX_iPhone -7

static CGFloat distanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

static CGPoint pointWithOffset(CGPoint p, CGPoint offset)
{
    return CGPointMake(p.x + offset.x, p.y + offset.y);
}

@interface SCHStoryInteractionControllerWhoSaidIt_iPad ()

@property (nonatomic, assign) CGPoint sourceCenterOffset;
@property (nonatomic, assign) CGPoint targetCenterOffset;

@end

@implementation SCHStoryInteractionControllerWhoSaidIt_iPad

@synthesize checkAnswersButton;
@synthesize statementLabels;
@synthesize sources;
@synthesize targets;
@synthesize sourceCenterOffset;
@synthesize targetCenterOffset;

- (void)dealloc
{
    [checkAnswersButton release];
    [statementLabels release];
    [sources release];
    [targets release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.targetCenterOffset = CGPointMake(kTargetOffsetX_iPad, 0);
        self.sourceCenterOffset = CGPointMake(0, kSourceOffsetY_iPad);
    } else {
        self.targetCenterOffset = CGPointMake(kTargetOffsetX_iPhone, 0);
        self.sourceCenterOffset = CGPointMake(0, kSourceOffsetY_iPhone);
    }
    
    // sort the arrays by vertical position to ensure the source labels and targets are ordered the same
    self.targets = [self.targets viewsSortedVertically];
    self.statementLabels = [self.statementLabels viewsSortedVertically];
    
    // set up the labels and tag the targets with the correct indices
    SCHStoryInteractionWhoSaidIt *whoSaidIt = (SCHStoryInteractionWhoSaidIt *)[self storyInteraction];
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionWhoSaidItStatement *statement in whoSaidIt.statements) {
        if (statement.questionIndex != whoSaidIt.distracterIndex) {
            [[self.statementLabels objectAtIndex:targetIndex] setText:statement.text];
            SCHStoryInteractionDraggableTargetView *target = [self.targets objectAtIndex:targetIndex];
            target.matchTag = statement.questionIndex;
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
        source.tag = -1;
        source.matchTag = statement.questionIndex;
        source.delegate = self;
        source.homePosition = source.center;
        [statements removeObjectAtIndex:index];
    }
    [statements release];
}

- (void)checkAnswers:(id)sender
{
    NSInteger correctCount = 0;
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        if (source.tag < 0) {
            continue;
        }
        SCHStoryInteractionDraggableTargetView *target = [self.targets objectAtIndex:source.tag];
        NSString *root;
        if (source.matchTag == target.matchTag) {
            correctCount++;
            root = @"storyinteraction-draggable-green-";
        } else {
            root = @"storyinteraction-draggable-red-";
        }
        UIImage *image = [UIImage imageNamed:[root stringByAppendingString:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone"]];
        UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
        imageView.highlightedImage = image;
        [imageView setHighlighted:YES];
    }

    if (correctCount == [self.targets count]) {
        [self playBundleAudioWithFilename:@"sfx_winround.mp3"
                               completion:^{
                                   [self removeFromHostView];
                               }];
    } else {
        // remove the highlights after a short delay
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            for (SCHStoryInteractionDraggableView *source in self.sources) {
                UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
                [imageView setHighlighted:NO];
            }
        });
    }
}

#pragma mark - draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    CGPoint sourceCenter = pointWithOffset(position, self.sourceCenterOffset);
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        CGPoint targetCenter = pointWithOffset(target.center, self.targetCenterOffset);
        if (distanceSq(sourceCenter, targetCenter) < kSnapDistanceSq) {
            *snapPosition = CGPointMake(targetCenter.x - self.sourceCenterOffset.x, targetCenter.y - self.sourceCenterOffset.y);
            return YES;
        }
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    // if we've landed on a target, tag the source with that target's index for checkAnswers
    draggableView.tag = -1;
    CGPoint sourceCenter = pointWithOffset(position, self.sourceCenterOffset);
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        CGPoint targetCenter = pointWithOffset(target.center, self.targetCenterOffset);
        if (distanceSq(sourceCenter, targetCenter) < kSnapDistanceSq) {
            draggableView.tag = targetIndex;
            break;
        }
        targetIndex++;
    }

    // if not attached to a target, move source back home
    if (draggableView.tag < 0) {
        [draggableView moveToHomePosition];
    }
    
    [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:nil];
}

@end
