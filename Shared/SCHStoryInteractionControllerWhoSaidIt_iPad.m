//
//  SCHStoryInteractionControllerWhoSaidIt.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerWhoSaidIt_iPad.h"
#import "SCHStoryInteractionWhoSaidItNameView.h"
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
@property (nonatomic, assign) NSInteger checkAnswersCount;

- (void)setCheckAnswersButtonEnabledState;

@end

@implementation SCHStoryInteractionControllerWhoSaidIt_iPad

@synthesize checkAnswersButton;
@synthesize winMessageLabel;
@synthesize statementLabels;
@synthesize sources;
@synthesize targets;
@synthesize sourceCenterOffset;
@synthesize targetCenterOffset;
@synthesize checkAnswersCount;
@synthesize sourceContainer;

- (void)dealloc
{
    [sourceContainer release];
    [checkAnswersButton release];
    [winMessageLabel release];
    [statementLabels release];
    [sources release];
    [targets release];
    [super dealloc];
}

- (CGSize)iPadContentsSizeForViewAtIndex:(NSInteger)viewIndex forOrientation:(UIInterfaceOrientation)orientation
{
    return (UIInterfaceOrientationIsLandscape(orientation)) ? CGSizeMake(848, 510) : CGSizeMake(690, 800);
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
        NSLog(@"%@ -> %@", statement.source, statement.text);
        if (statement.questionIndex != whoSaidIt.distracterIndex) {
            if (targetIndex < [self.statementLabels count]) {
                [[self.statementLabels objectAtIndex:targetIndex] setText:statement.text];
            }
            if (targetIndex < [self.targets count]) {
                SCHStoryInteractionDraggableTargetView *target = [self.targets objectAtIndex:targetIndex];
                target.matchTag = statement.questionIndex;
            }
            targetIndex++;
        }
    }
    
    // jumble up the sources and tag with the correct indices
    NSArray *statements = [whoSaidIt.statements shuffled];
    NSInteger index = 0;
    for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
        
        // move sources to contentsView so they can be moved around freely
        CGPoint center = [self.sourceContainer convertPoint:source.center toView:self.contentsView];
        [source removeFromSuperview];
        [self.contentsView addSubview:source];
        source.center = center;
        
        UILabel *label = (UILabel *)[source viewWithTag:kSourceLabelTag];
        source.attachedTarget = nil;        
        source.delegate = self;
        source.homePosition = center;        
        if (index < [statements count]) {
            SCHStoryInteractionWhoSaidItStatement *statement = [statements objectAtIndex:index];
            label.text = statement.source;            
            source.matchTag = statement.questionIndex;
        }
        index++;
    }
    
    [self.checkAnswersButton setEnabled:NO];
    self.checkAnswersCount = 0;
    self.winMessageLabel.hidden = YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    static const CGFloat kMinimumSourceGap = 5;
    static const CGFloat kMaximumSourceGap = 25;
    
    NSInteger sourceCount = [self.sources count];
    CGSize sourceSize = [[self.sources objectAtIndex:0] bounds].size;
    CGSize containerSize = self.sourceContainer.bounds.size;

    NSInteger sourceRows = 1;
    CGFloat sourceVerticalGap = 0;
    if ((sourceSize.width+kMinimumSourceGap)*sourceCount > containerSize.width) {
        sourceRows = 2;
        sourceVerticalGap = MAX(kMinimumSourceGap, containerSize.height-2*sourceSize.height);
    }

    NSInteger sourcesPerRow = sourceCount / sourceRows;
    CGFloat sourceHorizontalGap = MIN(kMaximumSourceGap, (containerSize.width-sourcesPerRow*sourceSize.width)/(sourcesPerRow-1));
    CGFloat sourceLeftInset = CGRectGetMinX(self.sourceContainer.frame) + (containerSize.width-sourcesPerRow*sourceSize.width-(sourcesPerRow-1)*sourceHorizontalGap)/2;
    CGFloat sourceTopInset = CGRectGetMinY(self.sourceContainer.frame);    
    
    NSInteger sourceIndex = 0;
    for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
        NSInteger row = sourceIndex % sourceRows;
        NSInteger col = sourceIndex / sourceRows;
        CGPoint center = CGPointMake(sourceSize.width/2 + sourceLeftInset + col*(sourceSize.width+sourceHorizontalGap),
                                     sourceSize.height/2 + sourceTopInset + row*(sourceSize.height+sourceVerticalGap));
        source.homePosition = center;
        if (source.attachedTarget != nil) {
            CGPoint targetCenter = [source.attachedTarget.superview convertPoint:pointWithOffset(source.attachedTarget.center, self.targetCenterOffset) toView:self.contentsView];
            source.center = CGPointMake(targetCenter.x - self.sourceCenterOffset.x, targetCenter.y - self.sourceCenterOffset.y);
        } else {
            source.center = center;
        }
        sourceIndex++;
    }
}

- (void)checkAnswers:(id)sender
{
    self.checkAnswersCount++;
    
    NSInteger correctCount = 0;
    for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
        source.userInteractionEnabled = NO;
        if (source.attachedTarget == nil) {
            continue;
        }
        NSString *imageName;
        if ([source attachedToCorrectTarget]) {
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
        for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
            if (![source attachedToCorrectTarget]) {
                source.hidden = YES;
            }
        }
        if (self.checkAnswersCount == 1) {
            self.winMessageLabel.text = NSLocalizedString(@"You did it! You won on your first try!", @"");
        } else {
            self.winMessageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You did it! You won in %d tries.", @""), self.checkAnswersCount];
        }
        self.checkAnswersButton.hidden = YES;
        self.winMessageLabel.hidden = NO;
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        
        [self enqueueAudioWithPath:@"sfx_winround.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                      [self removeFromHostView];
                  });
              }];
    } else {
        [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
            // remove the highlights after a short delay
            [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                // leave correct answers locked in place, send others home
                for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
                    if ([source attachedToCorrectTarget]) {
                        source.lockedInPlace = YES;
                    } else {
                        // send incorrect answers back to home position
                        UIImageView *imageView = (UIImageView *)[source viewWithTag:kSourceImageTag];
                        [imageView setHighlighted:NO];
                        [source moveToHomePositionWithCompletionHandler:^{
                            source.userInteractionEnabled = YES;
                        }];
                    }
                }
                [self setCheckAnswersButtonEnabledState];
            });
        }];
    }
}

- (SCHStoryInteractionWhoSaidItNameView *)nameViewOnTarget:(SCHStoryInteractionDraggableTargetView *)target
{
    for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
        if (source.attachedTarget == target) {
            return source;
        }
    }
    return nil;
}

- (void)setCheckAnswersButtonEnabledState
{
    BOOL anyAnswersOnTargets = NO;
    for (SCHStoryInteractionWhoSaidItNameView *source in self.sources) {
        if (source.attachedTarget != nil && !source.lockedInPlace) {
            anyAnswersOnTargets = YES;
            break;
        }
    }
    self.checkAnswersButton.enabled = anyAnswersOnTargets;
}

#pragma mark - draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    CGPoint sourceCenter = pointWithOffset(position, self.sourceCenterOffset);
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        CGPoint targetCenter = [target.superview convertPoint:pointWithOffset(target.center, self.targetCenterOffset) toView:self.contentsView];
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
    SCHStoryInteractionWhoSaidItNameView *source = (SCHStoryInteractionWhoSaidItNameView *)draggableView;
    
    // if we've landed on a target, send any current occupant home then attach to the target
    CGPoint sourceCenter = pointWithOffset(position, self.sourceCenterOffset);
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        CGPoint targetCenter = [target.superview convertPoint:pointWithOffset(target.center, self.targetCenterOffset) toView:self.contentsView];
        if (SCHCGPointDistanceSq(sourceCenter, targetCenter) < kSnapDistanceSq) {
            [[self nameViewOnTarget:target] moveToHomePosition];
            source.attachedTarget = target;
            break;
        }
    }

    // if not attached to a target, move source back home
    if (source.attachedTarget == nil) {
        [source moveToHomePosition];
    }
    
    [self enqueueAudioWithPath:@"sfx_dropOK.mp3" fromBundle:YES];
    [self setCheckAnswersButtonEnabledState];
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
