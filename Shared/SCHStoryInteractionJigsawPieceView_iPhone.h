//
//  SCHStoryInteractionJigsawPieceView_iPhone.h
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHDragFromScrollViewGestureRecognizer.h"
#import "SCHStoryInteractionJigsawPieceView.h"

@interface SCHStoryInteractionJigsawPieceView_iPhone : UIView <SCHStoryInteractionJigsawPieceView> {}

@property (nonatomic, assign) CGPoint homePosition;

- (void)addDragFromScrollerGestureRecognizerWithTarget:(id)target
                                                action:(SEL)action
                                             container:(UIView *)containerView
                                             direction:(enum SCHDragFromScrollViewGestureRecognizerDirection)direction;

- (void)moveToHomePosition;

@end
