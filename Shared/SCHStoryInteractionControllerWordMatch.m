//
//  SCHStoryInteractionControllerWordMatch.m
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerWordMatch.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionWordMatch.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"
#import "NSArray+ViewSorting.h"

#define kNumberOfItems 3
#define kLabelTag 101
#define kImageViewTag 102
#define kSnapDistanceSq 900
#define kSourceOffsetY 5

static CGFloat distanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

@interface SCHStoryInteractionControllerWordMatch ()

@property (nonatomic, assign) NSInteger currentQuestionIndex;
@property (nonatomic, retain) NSMutableSet *occupiedTargets;
@property (nonatomic, assign) NSInteger numberOfCorrectItems;

- (void)setupQuestion;
- (SCHStoryInteractionWordMatchQuestion *)currentQuestion;
- (void)checkForCompletion;

@end

@implementation SCHStoryInteractionControllerWordMatch

@synthesize wordViews;
@synthesize targetViews;
@synthesize imageViews;
@synthesize currentQuestionIndex;
@synthesize occupiedTargets;
@synthesize numberOfCorrectItems;

- (void)dealloc
{
    [wordViews release];
    [targetViews release];
    [imageViews release];
    [occupiedTargets release];
    [super dealloc];
}

- (SCHStoryInteractionWordMatchQuestion *)currentQuestion
{
    return [[(SCHStoryInteractionWordMatch *)self.storyInteraction questions] objectAtIndex:self.currentQuestionIndex];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    self.wordViews = [self.wordViews viewsSortedHorizontally];
    self.targetViews = [self.targetViews viewsSortedHorizontally];
    self.imageViews = [self.imageViews viewsSortedHorizontally];

    self.currentQuestionIndex = 0;
    // get the current question
    if (self.delegate && [self.delegate respondsToSelector:@selector(currentQuestionForStoryInteraction)]) {
        self.currentQuestionIndex += [self.delegate currentQuestionForStoryInteraction];    
    }
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.layer.borderWidth = 2;
        imageView.layer.borderColor = [[UIColor colorWithRed:0.165 green:0.322 blue:0.678 alpha:1.] CGColor];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
    }
    
    self.occupiedTargets = [NSMutableSet set]; 
    
    [self setupQuestion];
}

- (void)setupQuestion
{
    SCHStoryInteractionWordMatchQuestion *question = [self currentQuestion];
    
    NSMutableArray *sources = [self.wordViews mutableCopy];
    self.numberOfCorrectItems = 0;
    
    for (NSInteger i = 0; i < kNumberOfItems; ++i) {
        NSInteger viewIndex = arc4random() % [sources count];
        SCHStoryInteractionDraggableView *source = [sources objectAtIndex:viewIndex];
        
        SCHStoryInteractionWordMatchQuestionItem *item = [question.items objectAtIndex:i];
        UIImage *image = [self imageAtPath:[item imagePath]];
        
        [(UILabel *)[source viewWithTag:kLabelTag] setText:item.text];
        [[self.imageViews objectAtIndex:i] setImage:image];

        [source setDelegate:self];
        [source setMatchTag:i];
        [source setHomePosition:source.center];
        [[self.targetViews objectAtIndex:i] setMatchTag:i];
        
        [sources removeObjectAtIndex:viewIndex];
    }
}

- (void)checkForCompletion
{
    if (self.numberOfCorrectItems == kNumberOfItems) {
        SCHStoryInteractionWordMatch *wordMatch = (SCHStoryInteractionWordMatch *)self.storyInteraction;
        [self playAudioAtPath:[wordMatch audioPathForGotThemAll]
                   completion:^{
                       [self removeFromHostViewWithSuccess:YES];
                   }];
    }
}

#pragma mark - draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    CGPoint sourceCenter = CGPointMake(position.x, position.y+kSourceOffsetY);
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionDraggableTargetView *target in self.targetViews) {
        if (![self.occupiedTargets containsObject:target]) {
            if (distanceSq(sourceCenter, target.center) < kSnapDistanceSq) {
                *snapPosition = CGPointMake(target.center.x, target.center.y-kSourceOffsetY);
                return YES;
            }
        }
        targetIndex++;
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    CGPoint sourceCenter = CGPointMake(position.x, position.y+kSourceOffsetY);
    SCHStoryInteractionDraggableTargetView *onTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targetViews) {
        if (![self.occupiedTargets containsObject:target]) {
            if (distanceSq(sourceCenter, target.center) < kSnapDistanceSq) {
                onTarget = target;
                break;
            }
        }
    }

    UIImageView *imageView = (UIImageView *)[draggableView viewWithTag:kImageViewTag];

    if (!onTarget) {
        [draggableView moveToHomePosition];
        [self playBundleAudioWithFilename:@"sfx_dropNo.mp3" completion:nil];        
    } else if (onTarget.matchTag != draggableView.matchTag) {
        UIImage* oldImage = [imageView.image retain];
        [imageView setImage:[UIImage imageNamed:@"storyinteraction-draggable-red"]];
        [self playAudioAtPath:[self.storyInteraction audioPathForTryAgain]
                   completion:^{
                       [imageView setImage:oldImage];
                       [draggableView moveToHomePosition];
                   }];
        [oldImage release];
    } else {
        self.numberOfCorrectItems++;
        [imageView setImage:[UIImage imageNamed:@"storyinteraction-draggable-green"]];
        [draggableView setUserInteractionEnabled:NO];
        [self.occupiedTargets addObject:onTarget];

        [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:nil];

        SCHStoryInteractionWordMatchQuestionItem *item = [[[self currentQuestion] items] objectAtIndex:onTarget.matchTag];
        [self enqueueAudioWithPath:[item audioPath]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self checkForCompletion];
              }];
    }
}

@end
