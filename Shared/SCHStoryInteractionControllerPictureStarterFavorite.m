//
//  SCHStoryInteractionControllerPictureStarterFavorite.m
//  Scholastic
//
//  Created by Neil Gall on 24/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerPictureStarterFavorite.h"

@implementation SCHStoryInteractionControllerPictureStarterFavorite

- (void)setupOpeningScreen
{
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"SCHStoryInteractionPictureStarterFavorite" owner:self options:nil];
    if ([nibObjects count] > 0) {
        [self.contentsView addSubview:[nibObjects objectAtIndex:0]];
    }
}

- (IBAction)goTapped:(id)sender
{
    [self presentNextView];
}

@end
