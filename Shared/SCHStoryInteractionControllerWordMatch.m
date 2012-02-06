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
#import "NSArray+Shuffling.h"
#import "SCHGeometry.h"

#define kNumberOfItems 3
#define kLabelTag 101
#define kImageViewTag 102
#define kSnapDistanceSq 900
#define kSourceOffsetY_iPad 5
#define kSourceOffsetY_iPhone 3

@interface SCHStoryInteractionControllerWordMatch ()

@property (nonatomic, assign) NSInteger sourceOffsetY;
@property (nonatomic, retain) NSMutableSet *occupiedTargets;
@property (nonatomic, assign) NSInteger numberOfCorrectItems;

- (void)setupQuestion;
- (SCHStoryInteractionWordMatchQuestion *)currentQuestion;
- (void)playWinSequenceAndClose;

@end

@implementation SCHStoryInteractionControllerWordMatch

@synthesize wordViews;
@synthesize targetViews;
@synthesize imageViews;
@synthesize sourceOffsetY;
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
    NSInteger currentQuestionIndex = [self.delegate currentQuestionForStoryInteraction];
    return [[(SCHStoryInteractionWordMatch *)self.storyInteraction questions] objectAtIndex:currentQuestionIndex];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // play question audio on first question only
    return ([self.delegate currentQuestionForStoryInteraction] == 0
            && ![self.delegate storyInteractionFinished]);
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    self.sourceOffsetY = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kSourceOffsetY_iPad : kSourceOffsetY_iPhone;
    
    self.wordViews = [self.wordViews viewsSortedHorizontally];
    self.targetViews = [self.targetViews viewsSortedHorizontally];
    self.imageViews = [self.imageViews viewsSortedHorizontally];

    for (UIImageView *imageView in self.imageViews) {
        imageView.layer.borderWidth = 2;
        imageView.layer.borderColor = [[UIColor SCHBlue3Color] CGColor];
        imageView.layer.cornerRadius = 6;
        imageView.layer.masksToBounds = YES;
    }
    
    for (UIView *view in self.targetViews) {
        view.layer.cornerRadius = 6;
        view.layer.masksToBounds = YES;
    }
    
    self.occupiedTargets = [NSMutableSet set]; 
    
    [self setupQuestion];
}

- (void)setupQuestion
{
    self.numberOfCorrectItems = 0;

    SCHStoryInteractionWordMatchQuestion *question = [self currentQuestion];
    
    NSArray *sources = [self.wordViews shuffled];
    for (NSInteger i = 0; i < kNumberOfItems; ++i) {
        SCHStoryInteractionDraggableView *source = [sources objectAtIndex:i];
        SCHStoryInteractionWordMatchQuestionItem *item = [question.items objectAtIndex:i];
        UIImage *image = [self imageAtPath:[item imagePath]];
        
        [(UILabel *)[source viewWithTag:kLabelTag] setText:item.text];
        [[self.imageViews objectAtIndex:i] setImage:image];

        [source setDelegate:self];
        [source setMatchTag:i];
        [source setHomePosition:source.center];
        [[self.targetViews objectAtIndex:i] setMatchTag:i];
    }
}

- (void)playWinSequenceAndClose
{
    [self enqueueAudioWithPath:[self audioPathForYouFoundThemAll]
                    fromBundle:NO
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self removeFromHostView];
          }];
}

#pragma mark - draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
    }];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    CGPoint sourceCenter = CGPointMake(position.x, position.y+self.sourceOffsetY);
    NSInteger targetIndex = 0;
    for (SCHStoryInteractionDraggableTargetView *target in self.targetViews) {
        if (![self.occupiedTargets containsObject:target]) {
            if (SCHCGPointDistanceSq(sourceCenter, target.center) < kSnapDistanceSq) {
                *snapPosition = CGPointMake(target.center.x, target.center.y-self.sourceOffsetY);
                return YES;
            }
        }
        targetIndex++;
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    CGPoint sourceCenter = CGPointMake(position.x, position.y+self.sourceOffsetY);
    SCHStoryInteractionDraggableTargetView *onTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targetViews) {
        if (![self.occupiedTargets containsObject:target]) {
            if (SCHCGPointDistanceSq(sourceCenter, target.center) < kSnapDistanceSq) {
                onTarget = target;
                break;
            }
        }
    }
    
    UIImageView *imageView = (UIImageView *)[draggableView viewWithTag:kImageViewTag];

    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        if (!onTarget) {
            [draggableView moveToHomePosition];
            [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];        
        } else if (onTarget.matchTag != draggableView.matchTag) {
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
            [self.occupiedTargets addObject:onTarget];
            UIImage* oldImage = [imageView.image retain];
            [imageView setImage:[UIImage imageNamed:@"storyinteraction-draggable-red"]];
            
            SCHStoryInteractionWordMatchQuestionItem *item = [[[self currentQuestion] items] objectAtIndex:draggableView.matchTag];
            [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                            fromBundle:YES];
            [self enqueueAudioWithPath:[item audioPath]
                            fromBundle:NO];
            [self enqueueAudioWithPath:[self.storyInteraction audioPathForTryAgain]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [imageView setImage:oldImage];
                      [draggableView moveToHomePosition];
                      [self.occupiedTargets removeObject:onTarget];
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }];
            [oldImage release];
        } else {
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
            self.numberOfCorrectItems++;
            [imageView setImage:[UIImage imageNamed:@"storyinteraction-draggable-green"]];
            [draggableView setLockedInPlace:YES];
            [draggableView setUserInteractionEnabled:NO];
            if (onTarget != nil) {
                [self.occupiedTargets addObject:onTarget];
            }
            
            // get the current item before any state changes, as this may advance currentQuestion
            SCHStoryInteractionWordMatchQuestionItem *item = [[[self currentQuestion] items] objectAtIndex:onTarget.matchTag];
            
            BOOL allCorrect = (self.numberOfCorrectItems == kNumberOfItems);
            if (allCorrect) {
                self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            }
            
            NSString *sfxFile = allCorrect ? @"sfx_win_y.mp3" : [self.storyInteraction storyInteractionCorrectAnswerSoundFilename];
            
            [self enqueueAudioWithPath:sfxFile
                            fromBundle:YES];
            [self enqueueAudioWithPath:[item audioPath]
                            fromBundle:NO];
            [self enqueueAudioWithPath:[self.storyInteraction audioPathForThatsRight]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      if (allCorrect) {
                          [self playWinSequenceAndClose];
                      } else {
                          self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                      }
                  }];
        }
    }];
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    for (SCHStoryInteractionDraggableView *source in self.wordViews) {
        [source setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    for (SCHStoryInteractionDraggableView *source in self.wordViews) {
        if (!source.lockedInPlace) {
            [source setUserInteractionEnabled:YES];
        }
    }
}



@end
