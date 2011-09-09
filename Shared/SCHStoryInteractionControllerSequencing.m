//
//  SCHStoryInteractionControllerSequencing.m
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerSequencing.h"
#import "SCHStoryInteractionSequencing.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"
#import "NSArray+ViewSorting.h"
#import "NSArray+Shuffling.h"

#define kImageViewTag 1234
#define kNumberOfImages 3
#define kOffsetX 0
#define kOffsetY -6
#define kSnapDistanceSq 900

@interface SCHStoryInteractionControllerSequencing ()

@property (nonatomic, retain) NSMutableDictionary *attachedImages;

- (void)setView:(UIView *)view borderColor:(UIColor *)color;
- (void)checkForAllCorrectAnswers;

@end

@implementation SCHStoryInteractionControllerSequencing

@synthesize imageContainers;
@synthesize imageViews;
@synthesize targets;
@synthesize attachedImages;

- (void)dealloc
{
    [imageContainers release];
    [imageViews release];
    [targets release];
    [attachedImages release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
    NSAssert([sequencing numberOfImages] == kNumberOfImages, @"controller/views designed for exactly 3 images!");

    self.imageContainers = [self.imageContainers viewsSortedHorizontally];
    self.imageViews = [self.imageViews viewsSortedHorizontally];
    self.targets = [self.targets viewsSortedHorizontally];
    
    NSArray *shuffledImages = [self.imageViews shuffled];
    for (NSInteger i = 0; i < kNumberOfImages; ++i) {
        UIImage *image = [self imageAtPath:[sequencing imagePathForIndex:i]];
        UIImageView *imageView = [shuffledImages objectAtIndex:i];
        imageView.image = image;
        imageView.tag = kImageViewTag;
        [self setView:imageView borderColor:[UIColor blueColor]];
        
        SCHStoryInteractionDraggableView *container = (SCHStoryInteractionDraggableView *)imageView.superview;
        container.homePosition = container.center;
        container.matchTag = i;
        container.delegate = self;
        
        SCHStoryInteractionDraggableTargetView *target = (SCHStoryInteractionDraggableTargetView *)[self.targets objectAtIndex:i];
        target.matchTag = i;
        target.layer.cornerRadius = 5;
        target.layer.masksToBounds = YES;
    }
    
    self.attachedImages = [NSMutableDictionary dictionary];
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setView:(UIView *)view borderColor:(UIColor *)color
{
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = 3;
    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
}

- (void)checkForAllCorrectAnswers
{
    if ([self.attachedImages count] != kNumberOfImages) {
        return;
    }
    
    BOOL allCorrect = YES;
    for (SCHStoryInteractionDraggableView *draggable in self.imageContainers) {
        SCHStoryInteractionDraggableTargetView *target = [self.attachedImages objectForKey:[NSNumber numberWithInteger:draggable.matchTag]];
        if (target.matchTag != draggable.matchTag) {
            allCorrect = NO;
            break;
        }
    }
    
    if (allCorrect) {
        // get image views in answer order
        NSArray *views = [self.imageContainers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(SCHStoryInteractionDraggableView *)obj1 matchTag] - [(SCHStoryInteractionDraggableView *)obj2 matchTag];
        }];
        
        // play 'that's right'
        SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
        [self enqueueAudioWithPath:[sequencing audioPathForThatsRight]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:^{
                self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            }
              synchronizedEndBlock:nil];
        
        // play all the answer audio files in turn
        for (NSInteger index = 0; index < kNumberOfImages; ++index) {
            [self enqueueAudioWithPath:[sequencing audioPathForCorrectAnswerAtIndex:index]
                            fromBundle:NO
                            startDelay:0.5
                synchronizedStartBlock:^{
                    [self setView:[[views objectAtIndex:index] viewWithTag:kImageViewTag] borderColor:[UIColor greenColor]];
                }
                  synchronizedEndBlock:^{
                      if (index == kNumberOfImages-1) {
                          [self removeFromHostView];
                      }
                  }];
        }
    } else {
        self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
        [self playAudioAtPath:[self.storyInteraction audioPathForTryAgain]
                   completion:^{
                       self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                       // move all images back to start
                       for (SCHStoryInteractionDraggableView *draggable in self.imageContainers) {
                           [draggable moveToHomePosition];
                           [self setView:[draggable viewWithTag:kImageViewTag] borderColor:[UIColor blueColor]];
                       }
                       [self.attachedImages removeAllObjects];
                   }];
    }
}

#pragma mark - draggable view delegate

static CGFloat distanceSq(CGPoint imageCenter, CGPoint targetCenter)
{
    CGFloat dx = (imageCenter.x - kOffsetX) - targetCenter.x;
    CGFloat dy = (imageCenter.y - kOffsetY) - targetCenter.y;
    return dx*dx+dy*dy;
}

- (BOOL)targetOccupied:(SCHStoryInteractionDraggableTargetView *)target
{
    return [[self.attachedImages allValues] containsObject:target];
}

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];

    [self.attachedImages removeObjectForKey:[NSNumber numberWithInteger:draggableView.matchTag]];
    [self setView:[draggableView viewWithTag:kImageViewTag] borderColor:[UIColor blueColor]];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        if (![self targetOccupied:target] && distanceSq(position, target.center) < kSnapDistanceSq) {
            *snapPosition = CGPointMake(target.center.x + kOffsetX, target.center.y + kOffsetY);
            return YES;
        }
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    SCHStoryInteractionDraggableTargetView *attachedTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        if (![self targetOccupied:target] && distanceSq(position, target.center) < kSnapDistanceSq) {
            attachedTarget = target;
            break;
        }
    }
    
    if (!attachedTarget) {
        [draggableView moveToHomePosition];
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];
        return;
    }

    [self.attachedImages setObject:attachedTarget forKey:[NSNumber numberWithInteger:draggableView.matchTag]];
    
    [self enqueueAudioWithPath:@"sfx_dropOK.mp3"
                    fromBundle:YES
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self checkForAllCorrectAnswers];
          }];
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    for (SCHStoryInteractionDraggableView *item in self.imageContainers) {
        [item setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    for (SCHStoryInteractionDraggableView *item in self.imageContainers) {
        [item setUserInteractionEnabled:YES];
    }
}



@end
