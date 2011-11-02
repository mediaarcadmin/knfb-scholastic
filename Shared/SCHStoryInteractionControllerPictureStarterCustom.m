//
//  SCHStoryInteractionControllerPictureStarter.m
//  Scholastic
//
//  Created by Neil Gall on 19/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarterCustom.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionPictureStarter.h"
#import "NSArray+ViewSorting.h"

@interface SCHStoryInteractionControllerPictureStarterCustom ()

@property (nonatomic, retain) NSArray *pictureStarterCustomViews;
@property (nonatomic, assign) NSInteger chosenBackgroundIndex;

@end

@implementation SCHStoryInteractionControllerPictureStarterCustom

@synthesize backgroundChooserButtons;
@synthesize introductionLabel;
@synthesize pictureStarterCustomViews;
@synthesize chosenBackgroundIndex;

- (void)dealloc
{
    [backgroundChooserButtons release], backgroundChooserButtons = nil;
    [introductionLabel release], introductionLabel = nil;
    [pictureStarterCustomViews release], pictureStarterCustomViews = nil;
    [super dealloc];
}

- (void)setupOpeningScreen
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    self.pictureStarterCustomViews = [[NSBundle mainBundle] loadNibNamed:@"SCHStoryInteractionPictureStarterCustom" owner:self options:nil];
    UIView *view = [self.pictureStarterCustomViews objectAtIndex:0];
    [self.contentsView addSubview:view];
    [self resizeCurrentViewToSize:view.bounds.size animationDuration:0 withAdditionalAdjustments:nil];
    
    SCHStoryInteractionPictureStarterCustom *pictureStarter = (SCHStoryInteractionPictureStarterCustom *)self.storyInteraction;
    for (UIButton *button in self.backgroundChooserButtons) {
        NSString *path = [pictureStarter imagePathAtIndex:button.tag];
        [button setBackgroundImage:[self imageAtPath:path] forState:UIControlStateNormal];
    }
    
    if (!iPad) {
        [self setTitle:NSLocalizedString(@"To get started, choose a picture below.", @"Picture Starter custom opening screen title, iPhone")];
    }
}

- (void)setupDrawingScreen
{
    [super setupDrawingScreen];
    
    if (self.chosenBackgroundIndex < 3) {
        SCHStoryInteractionPictureStarterCustom *pictureStarter = (SCHStoryInteractionPictureStarterCustom *)self.storyInteraction;
        
        UIView *introView = [self.pictureStarterCustomViews objectAtIndex:1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            introView.bounds = CGRectMake(0, 0, introView.bounds.size.height, introView.bounds.size.width);
        }
        
        self.introductionLabel.text = [pictureStarter introductionAtIndex:self.chosenBackgroundIndex];
        [self.containerView addSubview:introView];
        introView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds), CGRectGetMidY(self.containerView.bounds));
        introView.alpha = 0;
        self.contentsView.userInteractionEnabled = NO;
                
        [self enqueueAudioWithPath:[pictureStarter audioPathAtIndex:self.chosenBackgroundIndex]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:^{
                [UIView animateWithDuration:0.25 animations:^{
                    introView.alpha = 1;
                }];
            }
              synchronizedEndBlock:nil];
    }
}

- (void)chooseBackground:(UIButton *)sender
{
    self.chosenBackgroundIndex = sender.tag;
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self presentNextView];
    }];
}

- (void)goTapped:(id)sender
{
    UIView *introView = [self.pictureStarterCustomViews objectAtIndex:1];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         introView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
                             [introView removeFromSuperview];
                             self.contentsView.userInteractionEnabled = YES;
                         }];
                     }];
}

- (UIImage *)drawingBackgroundImage
{
    SCHStoryInteractionPictureStarterCustom *pictureStarter = (SCHStoryInteractionPictureStarterCustom *)self.storyInteraction;
    return [self imageAtPath:[pictureStarter imagePathAtIndex:self.chosenBackgroundIndex]];
}

@end
