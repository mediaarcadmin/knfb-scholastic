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
#import "NSArray+Shuffling.h"
#import "SCHGeometry.h"

#define kSourceLabelTag 1001
#define kSourceImageTag 1002
#define kSnapDistanceSq 900
#define kSourceOffsetY_iPad 5
#define kSourceOffsetY_iPhone 3
#define kTargetOffsetX_iPad -13
#define kTargetOffsetX_iPhone -7

static CGPoint pointWithOffset(CGPoint p, CGPoint offset)
{
    return CGPointMake(p.x + offset.x, p.y + offset.y);
}

@interface SCHStoryInteractionControllerWhoSaidIt_iPad ()

@property (nonatomic, assign) CGPoint sourceCenterOffset;
@property (nonatomic, assign) CGPoint targetCenterOffset;
@property (nonatomic, retain) NSMutableDictionary *currentOccupants;

@end

@implementation SCHStoryInteractionControllerWhoSaidIt_iPad

@synthesize checkAnswersButton;
@synthesize statementLabels;
@synthesize sources;
@synthesize targets;
@synthesize sourceCenterOffset;
@synthesize targetCenterOffset;
@synthesize currentOccupants;

- (void)dealloc
{
    [checkAnswersButton release];
    [statementLabels release];
    [sources release];
    [targets release];
    [currentOccupants release];
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
    self.currentOccupants = [NSMutableDictionary dictionary];
    
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
    NSArray *statements = [whoSaidIt.statements shuffled];
    NSInteger index = 0;
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        SCHStoryInteractionWhoSaidItStatement *statement = [statements objectAtIndex:index];
        UILabel *label = (UILabel *)[source viewWithTag:kSourceLabelTag];
        label.text = statement.source;
        source.tag = -1;
        source.matchTag = statement.questionIndex;
        source.delegate = self;
        source.homePosition = source.center;
        index++;
    }
}

- (void)checkAnswers:(id)sender
{
    NSInteger correctCount = 0;
    for (SCHStoryInteractionDraggableView *source in self.sources) {
        if (source.tag < 0) {
            continue;
        }
        SCHStoryInteractionDraggableTargetView *target = [self.targets objectAtIndex:source.tag];
        NSString *imageName;
        if (source.matchTag == target.matchTag) {
            correctCount++;
            imageName = @"storyinteraction-draggable-green";
        } else {
            imageName = @"storyinteraction-draggable-red";
        }
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
        imageView.highlightedImage = image;
        [imageView setHighlighted:YES];
    }

    if (correctCount == [self.targets count]) {
        
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        
        [self playBundleAudioWithFilename:@"sfx_winround.mp3"
                               completion:^{
                                   [self removeFromHostView];
                               }];
    } else {
        [self playDefaultButtonAudio];
        // remove the highlights after a short delay
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            for (SCHStoryInteractionDraggableView *source in self.sources) {
                UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
                [imageView setHighlighted:NO];
                
                // send incorrect answers back to home position
                if (source.tag >= 0 && [[self.targets objectAtIndex:source.tag] matchTag] != source.matchTag) {
                    [source moveToHomePosition];
                    source.tag = -1;
                }
            }
        });
    }
}

#pragma mark - draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
    
    if (draggableView.tag >= 0) {
        [self.currentOccupants removeObjectForKey:[NSNumber numberWithInteger:draggableView.tag]];
    }
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    CGPoint sourceCenter = pointWithOffset(position, self.sourceCenterOffset);
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        CGPoint targetCenter = pointWithOffset(target.center, self.targetCenterOffset);
        if (SCHCGPointDistanceSq(sourceCenter, targetCenter) < kSnapDistanceSq) {
            *snapPosition = CGPointMake(targetCenter.x - self.sourceCenterOffset.x, targetCenter.y - self.sourceCenterOffset.y);
            return YES;
        }
        targetIndex++;
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
        if (SCHCGPointDistanceSq(sourceCenter, targetCenter) < kSnapDistanceSq) {
            NSNumber *targetIndexObj = [NSNumber numberWithInteger:targetIndex];
            SCHStoryInteractionDraggableView *currentOccupant = [self.currentOccupants objectForKey:targetIndexObj];
            [currentOccupant moveToHomePosition];
            currentOccupant.tag = -1;
            draggableView.tag = targetIndex;
            [self.currentOccupants setObject:draggableView forKey:targetIndexObj];
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

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    [checkAnswersButton setUserInteractionEnabled:NO];
    
    for (SCHStoryInteractionDraggableView *source in sources) {
        [source setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    [checkAnswersButton setUserInteractionEnabled:YES];
    
    for (SCHStoryInteractionDraggableView *source in sources) {
        UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
        if (![imageView isHighlighted]) {
            [source setUserInteractionEnabled:YES];
        }
    }
}



@end
