//
//  SCHStoryInteractionControllerStartingLetter.m
//  Scholastic
//
//  Created by John S. Eddie on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerStartingLetter.h"

#import <QuartzCore/QuartzCore.h>
#import "SCHStoryInteractionStartingLetter.h"
#import "KNFBXPSProvider.h"
#import "SCHImageButton.h"

@interface SCHStoryInteractionControllerStartingLetter ()

@property (nonatomic, assign) NSInteger simultaneousTapCount;

- (void)shuffleImageButtons;
- (SCHStoryInteractionStartingLetterQuestion *)questionAtIndex:(NSUInteger)index;
- (void)answerChosen:(SCHImageButton *)imageButton;
- (BOOL)questionsCompleted;
- (void)setupButtonsForOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation SCHStoryInteractionControllerStartingLetter

@synthesize imageButtons;
@synthesize buttonContainerView;
@synthesize simultaneousTapCount;

- (void)dealloc
{
    [imageButtons release], imageButtons = nil;
    
    [super dealloc];
}

- (void)shuffleImageButtons 
{
    NSMutableArray *shuffleArray = [NSMutableArray arrayWithArray:self.imageButtons];
    NSUInteger i = 0;
    SCHImageButton *imageButton = nil;
    
    // create a Fisher–Yates shuffled array
    srand(time(NULL));
    for (i = [shuffleArray count] - 1; i > 0; i--)
    {
        [shuffleArray exchangeObjectAtIndex:(rand() % i) withObjectAtIndex:i];
    }    
    
    // assign new tags for the image buttons
    for (i = 0; i < [shuffleArray count]; i++) {
        imageButton = [shuffleArray objectAtIndex:i];
        imageButton.tag = i + 1;
    }
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    self.simultaneousTapCount = 0;
    
    [self setTitle:[(SCHStoryInteractionStartingLetter *)self.storyInteraction prompt]];
    [self setupButtonsForOrientation:self.interfaceOrientation];

    [self shuffleImageButtons];
    for (SCHImageButton *imageButton in self.imageButtons) {
        SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1];
        if (question != nil) {
            NSString *imagePath = [question imagePath];
            NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
            if (imageData != nil) {
                imageButton.image = [UIImage imageWithData:imageData];
            }
            imageButton.normalColor = [UIColor SCHBlue2Color];
            imageButton.selectedColor = ([question isCorrect] == NO ? [UIColor SCHScholasticRedColor] : [UIColor SCHGreen1Color]);                        
            imageButton.actionBlock = ^(SCHImageButton *imageButton) {
                [self answerChosen:imageButton];
            };
        }
    }
}

- (SCHStoryInteractionStartingLetterQuestion *)questionAtIndex:(NSUInteger)index
{
    SCHStoryInteractionStartingLetterQuestion *ret = nil;
    
    if (index < [[(SCHStoryInteractionStartingLetter *)self.storyInteraction questions] count]) {
        ret = [[(SCHStoryInteractionStartingLetter *)self.storyInteraction questions] objectAtIndex:index];
    }
    
    return(ret);
}

- (void)answerChosen:(SCHImageButton *)imageButton
{
    self.simultaneousTapCount++;
    if (self.simultaneousTapCount == 1) {
        [self performSelector:@selector(answerChosenAfterDelay:) withObject:imageButton afterDelay:kMinimumDistinguishedAnswerDelay];
    }
}


- (void)answerChosenAfterDelay:(SCHImageButton *)imageButton
{
//    // ignore multiple taps
//    if (self.controllerState != SCHStoryInteractionControllerStateInteractionInProgress) {
//        return;
//    }
//    
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
        self.simultaneousTapCount = 0;
        
        imageButton.selected = YES;
        SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1]; 
        if (question != nil) {
            if ([question isCorrect] == YES) {
                BOOL questionsCompleted = [self questionsCompleted];
                if (questionsCompleted) {
                    [self enqueueAudioWithPath:@"sfx_win_y.mp3" fromBundle:YES];
                    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
                } else {
                    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
                }
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForThatsRight] fromBundle:NO];
                [self enqueueAudioWithPath:[question audioPath] fromBundle:NO];
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForStartsWith] fromBundle:NO];
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForLetter] 
                                fromBundle:NO 
                                startDelay:0
                    synchronizedStartBlock:nil
                      synchronizedEndBlock:^{
                          if (!questionsCompleted) {
                              self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                          }
                      }];
                
                if (questionsCompleted) {
                    [self enqueueAudioWithPath:[self audioPathForYouFoundThemAll]
                                    fromBundle:NO
                                    startDelay:0
                        synchronizedStartBlock:nil
                          synchronizedEndBlock:^{
                              [self removeFromHostView];
                          }];
                };
            } else {
                [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename] fromBundle:YES];
                [self enqueueAudioWithPath:[question audioPath] fromBundle:NO];
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForDoesntStartWith] fromBundle:NO];
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForLetter] fromBundle:NO];
                [self enqueueAudioWithPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForTryAgain] 
                                fromBundle:NO 
                                startDelay:0 
                    synchronizedStartBlock:nil 
                      synchronizedEndBlock:^{
                          self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                      }];
            }
        }   
        
    }];
}

- (BOOL)questionsCompleted
{
    BOOL ret = YES;
    
    for (SCHImageButton *imageButton in self.imageButtons) {
        SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1];
        if (question != nil && [question isCorrect] == YES && imageButton.selected == NO) {
            ret = NO;
            break;
        }
    }
    
    return(ret);
}

#pragma mark - Rotation for iPhone

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    [super rotateToOrientation:orientation];
    [self setupButtonsForOrientation:orientation];
}

- (void)setupButtonsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            self.buttonContainerView.frame = CGRectMake(118, 0, 235, 250);
        } else {
            self.buttonContainerView.frame = CGRectMake(1, 33, 310, 340);
        }
    }
}


#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    for (UIButton *button in self.imageButtons) {
        [button setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    for (UIButton *button in self.imageButtons) {
        [button setUserInteractionEnabled:YES];
    }
}



@end
