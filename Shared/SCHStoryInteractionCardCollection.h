//
//  SCHStoryInteractionCardCollection.h
//  Scholastic
//
//  Created by Neil Gall on 02/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionCardCollectionCard : SCHStoryInteractionQuestion {}
@property (nonatomic, retain) NSString *frontFilename;
@property (nonatomic, retain) NSString *backFilename;
@end

@interface SCHStoryInteractionCardCollection : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *headerFilename;
@property (nonatomic, retain) NSArray *cards;

- (NSString *)imagePathForHeader;

- (NSInteger)numberOfCards;
- (NSString *)imagePathForCardFrontAtIndex:(NSInteger)index;
- (NSString *)imagePathForCardBackAtIndex:(NSInteger)index;

@end
