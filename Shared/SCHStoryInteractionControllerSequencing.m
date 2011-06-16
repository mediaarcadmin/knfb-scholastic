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

    [self playAudioAtPath:[sequencing audioPathForQuestion] completion:nil];
    
    self.imageContainers = [self.imageContainers viewsSortedHorizontally];
    self.imageViews = [self.imageViews viewsSortedHorizontally];
    self.targets = [self.targets viewsSortedHorizontally];
    
    NSMutableArray *views = [NSMutableArray arrayWithArray:self.imageViews];
    for (NSInteger i = 0; i < kNumberOfImages; ++i) {
        UIImage *image = [self imageAtPath:[sequencing imagePathForIndex:i]];
        NSInteger pos = arc4random() % [views count];
        UIImageView *view = [views objectAtIndex:pos];
        view.image = image;
        view.tag = kImageViewTag;
        [self setView:view borderColor:[UIColor blueColor]];
        
        SCHStoryInteractionDraggableView *container = (SCHStoryInteractionDraggableView *)view.superview;
        container.homePosition = container.center;
        container.matchTag = i;
        container.delegate = self;
        
        SCHStoryInteractionDraggableTargetView *target = (SCHStoryInteractionDraggableTargetView *)[self.targets objectAtIndex:i];
        target.matchTag = i;
        target.layer.cornerRadius = 5;
        target.layer.masksToBounds = YES;
        
        [views removeObjectAtIndex:pos];
    }
    
    self.attachedImages = [NSMutableDictionary dictionary];
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
        
        // play all the audio files in turn
        SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
        __block NSInteger index = 0;
        __block dispatch_block_t playBlock;
        playBlock = Block_copy(^{
            if (index < kNumberOfImages) {
                dispatch_block_t playBlockCopy = Block_copy(playBlock);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self setView:[[views objectAtIndex:index] viewWithTag:kImageViewTag] borderColor:[UIColor greenColor]];
                    [self playAudioAtPath:[sequencing audioPathForCorrectAnswerAtIndex:index++] completion:playBlockCopy];
                });
                Block_release(playBlockCopy);
            } else {
                [self removeFromHostViewWithSuccess:YES];
            }
        });
        [self playAudioAtPath:[sequencing audioPathForThatsRight] completion:playBlock];
        Block_release(playBlock);
    } else {
        [self playAudioAtPath:[self.storyInteraction audioPathForTryAgain]
                   completion:^{
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
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
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
        [self playBundleAudioWithFilename:@"sfx_dropNo.mp3" completion:nil];
        return;
    }

    [self.attachedImages setObject:attachedTarget forKey:[NSNumber numberWithInteger:draggableView.matchTag]];
    
    [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:^{
        [self checkForAllCorrectAnswers];
    }];
}

@end
