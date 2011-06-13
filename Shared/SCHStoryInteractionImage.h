//
//  SCHStoryInteractionImage.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteraction.h"

@interface SCHStoryInteractionImage : SCHStoryInteraction {}

@property (nonatomic, retain) NSString *imageFilename;

// XPSProvider-relative path for the image
- (NSString *)imagePath;

@end
