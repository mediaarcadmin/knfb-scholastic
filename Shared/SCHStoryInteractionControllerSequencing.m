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

@end

@implementation SCHStoryInteractionControllerSequencing

@synthesize imageContainers;
@synthesize imageViews;
@synthesize targets;
@synthesize attachedImages;
@synthesize targetLabels;

- (void)dealloc
{
    [imageContainers release];
    [imageViews release];
    [targets release];
    [attachedImages release];
    [targetLabels release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
    NSAssert([sequencing numberOfImages] == kNumberOfImages, @"controller/views designed for exactly 3 images!");

    self.imageContainers = [self.imageContainers viewsSortedHorizontally];
    self.imageViews = [self.imageViews viewsSortedHorizontally];
    self.targets = [self.targets viewsSortedHorizontally];
    self.targetLabels = [self.targetLabels viewsSortedHorizontally];
    
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

- (void)layoutViewsForPhoneOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGRect containerRect = CGRectMake(0, 0, 310, 410);
        for (NSInteger rowIndex = 0; rowIndex < 3; ++rowIndex) {
            CGFloat y = CGRectGetHeight(containerRect)/6*(rowIndex*2+1);
            CGFloat x = CGRectGetWidth(containerRect)*3/4;
            [[self.targets objectAtIndex:rowIndex] setCenter:CGPointMake(x, y)];

            SCHStoryInteractionDraggableView *image = [self.imageContainers objectAtIndex:rowIndex];
            [image setHomePosition:CGPointMake(CGRectGetWidth(containerRect)/4, y)];
            
            SCHStoryInteractionDraggableTargetView *target = [self.attachedImages objectForKey:[NSNumber numberWithInteger:image.matchTag]];
            if (target) {
                NSInteger attachedRow = [self.targets indexOfObject:target];
                [image setCenter:CGPointMake(x, CGRectGetHeight(containerRect)/6*(attachedRow*2+1))];
            } else {
                [image setCenter:image.homePosition];
            }
        } 
    } else {
        CGRect containerRect = CGRectMake(0, 0, 470, 250);
        for (NSInteger columnIndex = 0; columnIndex < 3; ++columnIndex) {
            CGFloat x = CGRectGetWidth(containerRect)/6*(columnIndex*2+1);
            CGFloat y = CGRectGetHeight(containerRect)*3/4;
            [[self.targets objectAtIndex:columnIndex] setCenter:CGPointMake(x, y)];
            
            SCHStoryInteractionDraggableView *image = [self.imageContainers objectAtIndex:columnIndex];
            [image setHomePosition:CGPointMake(x, CGRectGetHeight(containerRect)/4)];
            
            SCHStoryInteractionDraggableTargetView *target = [self.attachedImages objectForKey:[NSNumber numberWithInteger:image.matchTag]];
            if (target) {
                NSInteger attachedRow = [self.targets indexOfObject:target];
                [image setCenter:CGPointMake(CGRectGetWidth(containerRect)/6*(attachedRow*2+1), y)];
            } else {
                [image setCenter:image.homePosition];
            }
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self layoutViewsForPhoneOrientation:toInterfaceOrientation];
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)setView:(UIView *)view borderColor:(UIColor *)color
{
    view.layer.borderColor = [color CGColor];
    view.layer.borderWidth = 3;
    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
}

- (BOOL)allAnswersAreCorrect
{
    if ([self.attachedImages count] != kNumberOfImages) {
        return NO;
    }
    
    for (SCHStoryInteractionDraggableView *draggable in self.imageContainers) {
        SCHStoryInteractionDraggableTargetView *target = [self.attachedImages objectForKey:[NSNumber numberWithInteger:draggable.matchTag]];
        if (target.matchTag != draggable.matchTag) {
            return NO;
        }
    }
    
    return YES;
}

- (void)playCorrectAnswerSequence
{
    // get image views in answer order
    NSArray *views = [self.imageContainers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(SCHStoryInteractionDraggableView *)obj1 matchTag] - [(SCHStoryInteractionDraggableView *)obj2 matchTag];
    }];
    
    [self enqueueAudioWithPath:@"sfx_win_y.mp3" fromBundle:YES];
    
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
                UILabel *label = [self.targetLabels objectAtIndex:index];
                label.textColor = [UIColor SCHGrayColor];
                label.backgroundColor = [UIColor SCHBlue2Color];
                label.layer.cornerRadius = 8;
            }
              synchronizedEndBlock:^{
                  if (index == kNumberOfImages-1) {
                      [self removeFromHostView];
                  }
              }];
    }
}

- (void)playIncorrectAnswerSequence
{
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename] fromBundle:YES];
    [self enqueueAudioWithPath:[self.storyInteraction audioPathForTryAgain]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              // move all images back to start
              for (SCHStoryInteractionDraggableView *draggable in self.imageContainers) {
                  [draggable moveToHomePosition];
                  [self setView:[draggable viewWithTag:kImageViewTag] borderColor:[UIColor blueColor]];
              }
              for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
                  target.alpha = 1;
              }
              [self.attachedImages removeAllObjects];
          }];
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
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
        
        NSNumber *matchKey = [NSNumber numberWithInteger:draggableView.matchTag];
        SCHStoryInteractionDraggableTargetView *attachedTarget = [self.attachedImages objectForKey:matchKey];
        if (attachedTarget) {
            attachedTarget.alpha = 1;
            [self.attachedImages removeObjectForKey:matchKey];
        }
        
        [self setView:[draggableView viewWithTag:kImageViewTag] borderColor:[UIColor blueColor]];
    }];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    SCHStoryInteractionDraggableTargetView *attachedTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        if (![self targetOccupied:target] && distanceSq(position, target.center) < kSnapDistanceSq) {
            attachedTarget = target;
            CGPoint position = CGPointMake(target.center.x + kOffsetX, target.center.y + kOffsetY);
            [UIView animateWithDuration:0.25f animations:^{
                draggableView.center = position;
                attachedTarget.alpha = 0;
            }];
            break;
        }
    }
    
    if (!attachedTarget) {
        [draggableView moveToHomePosition];
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];
        return;
    }

    [self.attachedImages setObject:attachedTarget forKey:[NSNumber numberWithInteger:draggableView.matchTag]];
    BOOL allCorrect = [self allAnswersAreCorrect];
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
    
    if ([self.attachedImages count] == 3) {
        if (allCorrect) {
            [self playCorrectAnswerSequence];
        } else {
            [self playIncorrectAnswerSequence];
        }
    } else {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }];
    }
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
