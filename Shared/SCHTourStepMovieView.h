//
//  SCHTourStepMovieView.h
//  Scholastic
//
//  Created by Gordon Christie on 01/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepImageView.h"

@interface SCHTourStepMovieView : SCHTourStepImageView

@property (nonatomic, retain) NSURL *movieURL;

- (void)startVideo;
- (void)stopVideo;

@end
