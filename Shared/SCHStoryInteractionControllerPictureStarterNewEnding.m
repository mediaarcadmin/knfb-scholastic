//
//  SCHStoryInteractionControllerPictureStarterNewEnding.m
//  Scholastic
//
//  Created by Neil Gall on 24/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarterNewEnding.h"

@implementation SCHStoryInteractionControllerPictureStarterNewEnding

- (void)setupOpeningScreen
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SCHStoryInteractionPictureStarterNewEnding" owner:self options:nil];
    if ([nibObjects count] > 0) {
        [self.contentsView addSubview:[nibObjects objectAtIndex:0]];
    }
}

- (IBAction)goTapped:(id)sender
{
    [self presentNextView];
}

- (NSString *)pictureStarterSavedImageName
{
    return @"SavedImage_PictureStarterNewEnding";
}

@end
