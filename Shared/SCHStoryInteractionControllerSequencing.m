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
    for (NSNumber *imageMatchTag in [self.attachedImages allKeys]) {
        SCHStoryInteractionDraggableTargetView *target = [self.attachedImages objectForKey:imageMatchTag];
        if ([imageMatchTag integerValue] != target.matchTag) {
            allCorrect = NO;
        }
    }
    
    if (allCorrect) {
        SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;
        [self playAudioAtPath:[sequencing audioPathForCorrectAnswer] completion:nil];
    } else {
        // move all images back to start
        for (SCHStoryInteractionDraggableView *draggable in self.imageContainers) {
            [draggable moveToHomePosition];
            [self setView:[draggable viewWithTag:kImageViewTag] borderColor:[UIColor blueColor]];
        }
        [self.attachedImages removeAllObjects];
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

    SCHStoryInteractionSequencing *sequencing = (SCHStoryInteractionSequencing *)self.storyInteraction;

    [self.attachedImages setObject:attachedTarget forKey:[NSNumber numberWithInteger:draggableView.matchTag]];
    
    [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:^{
        UIImageView *imageView = (UIImageView *)[draggableView viewWithTag:kImageViewTag];
        if (draggableView.matchTag == attachedTarget.matchTag) {
            [self setView:imageView borderColor:[UIColor greenColor]];
            [self playAudioAtPath:[sequencing audioPathForCorrectAnswerAtIndex:attachedTarget.matchTag]
                       completion:^{
                           [self checkForAllCorrectAnswers];
                       }];
        } else {
            [self setView:imageView borderColor:[UIColor blueColor]];
            [self checkForAllCorrectAnswers];
        }
    }];
}

@end
