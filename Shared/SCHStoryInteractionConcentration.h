//
//  SCHStoryInteractionConcentration.h
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionConcentration : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *introduction;

- (NSString *)audioPathForIntroduction;
- (NSString *)audioPathForYouWon;

- (NSInteger)numberOfPairs;
- (NSString *)imagePathForFirstOfPairAtIndex:(NSInteger)index;
- (NSString *)imagePathForSecondOfPairAtIndex:(NSInteger)index;

@end
