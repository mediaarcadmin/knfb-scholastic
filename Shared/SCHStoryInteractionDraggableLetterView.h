//
//  SCHStoryInteractionDraggableLetterView.h
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionDraggableView.h"

@interface SCHStoryInteractionDraggableLetterView : SCHStoryInteractionDraggableView {}

@property (nonatomic, readonly) unichar letter;

- (id)initWithLetter:(unichar)letter;

@end
