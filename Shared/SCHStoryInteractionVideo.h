//
//  SCHStoryInteractionVideo.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionVideo : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *videoTranscript;
@property (nonatomic, retain) NSString *videoFilename;

// XPSProvider-relative path for question
- (NSString *)audioPathForQuestion;

// XPSProvider-relative path
- (NSString *)videoPath;

@end
