//
//  SCHReadingStoryInteractionButton.h
//  Scholastic
//
//  Created by Matt Farrugia on 22/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHReadingStoryInteractionButton : UIButton

@property (nonatomic, assign) BOOL isYounger;
@property (nonatomic, assign) float fillLevel;

- (void)setFillLevel:(float)fillLevel animated:(BOOL)animated;

@end
