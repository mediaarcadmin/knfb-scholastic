//
//  SCHStoryInteractionPictureStarter.h
//  Scholastic
//
//  Created by Neil Gall on 02/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionPictureStarter : SCHStoryInteraction {}

@property (nonatomic, retain) NSArray *introductions;

- (NSString *)audioPathForIntroduction;

- (NSString *)introductionAtIndex:(NSInteger)index;
- (NSString *)audioPathAtIndex:(NSInteger)index;
- (NSString *)imagePathAtIndex:(NSInteger)index;
- (NSString *)audioPathForClearThisPicture;

@end

@interface SCHStoryInteractionPictureStarterCustom : SCHStoryInteractionPictureStarter {}
@end

@interface SCHStoryInteractionPictureStarterNewEnding : SCHStoryInteractionPictureStarter {}
@end

@interface SCHStoryInteractionPictureStarterFavorite : SCHStoryInteractionPictureStarter {}
@end
