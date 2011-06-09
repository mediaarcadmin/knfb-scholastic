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

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [self setTitle:[(SCHStoryInteractionStartingLetter *)self.storyInteraction prompt]];
    
    for (SCHImageButton *imageButton in self.imageButtons) {
        SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1];
        if (question != nil) {
            NSString *imagePath = [question imagePath];
            NSData *imageData = [self.xpsProvider dataForComponentAtPath:imagePath];
            if (imageData != nil) {
                imageButton.image = [UIImage imageWithData:imageData];
            }
            imageButton.normalColor = [UIColor blueColor];
            imageButton.selectedColor = ([question isCorrect] == NO ? [UIColor redColor] : [UIColor greenColor]);            
            imageButton.actionBlock = ^(SCHImageButton *imageButton) {
                SCHStoryInteractionStartingLetterQuestion *question = [self questionAtIndex:imageButton.tag - 1]; 
                if (question != nil) {
                    [self playAudioAtPath:[question audioPath] completion:^{
                        [self questionsCompleted];
                    }];                    
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
        [self removeFromHostView];
    }

    return(ret);
}

- (NSString *)audioPath
{
    return([(SCHStoryInteractionStartingLetter *)self.storyInteraction audioPath]);
}

@end
