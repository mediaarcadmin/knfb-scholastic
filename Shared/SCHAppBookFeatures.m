//
//  SCHAppBookFeatures.m
//  Scholastic
//
//  Created by John S. Eddie on 13/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHAppBookFeatures.h"

@interface SCHAppBookFeatures ()

@property (nonatomic, assign) SCHAppBookFeaturesFeatures features;

@end

@implementation SCHAppBookFeatures

@synthesize features;

- (id)initWithStoryInteractions:(BOOL)storyInteractions
                          audio:(BOOL)audio
                         sample:(BOOL)sample
{
    self = [super init];
    if (self) {
        features = kSCHAppBookFeaturesNone;
        
        if (storyInteractions == YES) {
            features |= kSCHAppBookFeaturesStoryInteractions;
        }

        if (audio == YES) {
            features |= kSCHAppBookFeaturesAudio;
        }

        if (sample) {
            features |= kSCHAppBookFeaturesSample;
        }
    }

    return self;
}

- (BOOL)hasStoryInteractions
{
    return (self.features & kSCHAppBookFeaturesStoryInteractions) == kSCHAppBookFeaturesStoryInteractions;
}

- (BOOL)hasAudio
{
    return (self.features & kSCHAppBookFeaturesAudio) == kSCHAppBookFeaturesAudio;
}

- (BOOL)isSample
{
    return (self.features & kSCHAppBookFeaturesSample) == kSCHAppBookFeaturesSample;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SI:%@ Audio:%@ Sample:%@",
            (self.hasStoryInteractions == YES ? @"Y" : @"N"),
            (self.hasAudio == YES? @"Y" : @"N"),
            (self.isSample == YES? @"Y" : @"N")];
}

@end
