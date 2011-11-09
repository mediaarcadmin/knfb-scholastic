//
//  SCHStoryInteractionJigsawPreviewView.h
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHStoryInteractionJigsawPaths;

@interface SCHStoryInteractionJigsawPreviewView : UIView

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) SCHStoryInteractionJigsawPaths *paths;
@property (nonatomic, retain) UIColor *edgeColor;

- (CGRect)puzzleBounds;

@end
