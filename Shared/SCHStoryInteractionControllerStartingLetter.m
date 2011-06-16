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

- (void)shuffleImageButtons;
- (SCHStoryInteractionStartingLetterQuestion *)questionAtIndex:(NSUInteger)index;
- (BOOL)questionsCompleted;

@end

@implementation SCHStoryInteractionControllerStartingLetter

@synthesize imageButtons;

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
    [self setTitle:[(SCHStoryInteractionStartingLetter *)self.storyInteraction prompt]];
    
    [self shuffleImageButtons];
    for (SCHImageButton *imageButton in self.imageButtons) {
        SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1];
        if (question != nil) {
            NSString *imagePath = [question imagePath];
            NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
            if (imageData != nil) {
                imageButton.image = [UIImage imageWithData:imageData];
            }
            imageButton.normalColor = [UIColor colorWithRed:0.071 green:0.396 blue:0.698 alpha:1.000];
            imageButton.selectedColor = ([question isCorrect] == NO ? [UIColor colorWithRed:0.973 green:0.004 blue:0.094 alpha:1.000] : [UIColor colorWithRed:0.157 green:0.753 blue:0.341 alpha:1.000]);            
            imageButton.actionBlock = ^(SCHImageButton *imageButton) {
                SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1]; 
                if (question != nil) {
                    if ([question isCorrect] == YES) {
                    [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForThatsRight] completion:^{                        
                        [self playAudioAtPath:[question audioPath] completion:^{
                            [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForStartsWith] completion:^{                        
                                [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForLetter] completion:^{                        
                                    [self questionsCompleted];
                                }];                                            
                            }];                    
                        }];                    
                    }];                                  
                    } else {
                        [self playAudioAtPath:[question audioPath] completion:^{                        
                            [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForDoesntStartWith] completion:^{                        
                                [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForLetter] completion:^{                        
                                    [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForTryAgain] completion:^{                                                            
                                        [self questionsCompleted];
                                    }];                                            
                                }];                                                                                
                            }];                    
                        }];                                                          
                    }
                }
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
    
    if (ret == YES) {
        [self playAudioAtPath:[(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPathForYouFoundThemAll] completion:^{
            [self removeFromHostViewWithSuccess:YES];
        }];
    }

    return(ret);
}

@end