//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 19/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarterCustom.h"
#import "SCHStoryInteractionPictureStarter.h"
#import "NSArray+ViewSorting.h"

@interface SCHStoryInteractionControllerPictureStarterCustom ()

@property (nonatomic, assign) NSInteger chosenBackgroundIndex;

@end

@implementation SCHStoryInteractionControllerPictureStarterCustom

@synthesize backgroundChooserButtons;
@synthesize chosenBackgroundIndex;

- (void)dealloc
{
    [backgroundChooserButtons release], backgroundChooserButtons = nil;
    [super dealloc];
}

- (void)setupOpeningScreen
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SCHStoryInteractionPictureStarterCustom" owner:self options:nil];
    [self.contentsView addSubview:[nibObjects objectAtIndex:0]];
    
    SCHStoryInteractionPictureStarter *pictureStarter = (SCHStoryInteractionPictureStarter *)self.storyInteraction;
    for (UIButton *button in self.backgroundChooserButtons) {
        NSString *path = [pictureStarter imagePathAtIndex:button.tag];
        [button setBackgroundImage:[self imageAtPath:path] forState:UIControlStateNormal];
    }
    
    [self enqueueAudioWithPath:@"gen_chooseyourpicture.mp3" fromBundle:NO];
}

- (void)chooseBackground:(UIButton *)sender
{
    self.chosenBackgroundIndex = sender.tag;
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self presentNextView];
}

- (UIImage *)drawingBackgroundImage
{
    SCHStoryInteractionPictureStarter *pictureStarter = (SCHStoryInteractionPictureStarter *)self.storyInteraction;
    return [self imageAtPath:[pictureStarter imagePathAtIndex:self.chosenBackgroundIndex]];
}

@end
