//
//  SCHFeatureButton.h
//  Scholastic
//
//  Created by John S. Eddie on 13/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSCHAppBookFeaturesNone = 0x0,
    kSCHAppBookFeaturesStoryInteractions = 0x1,
    kSCHAppBookFeaturesAudio = 0x2,
    kSCHAppBookFeaturesSample = 0x4,

    kSCHAppBookFeaturesStoryInteractionsAudio = kSCHAppBookFeaturesStoryInteractions | kSCHAppBookFeaturesAudio,
    kSCHAppBookFeaturesStoryInteractionsSample = kSCHAppBookFeaturesStoryInteractions | kSCHAppBookFeaturesSample,
    kSCHAppBookFeaturesAudioSample = kSCHAppBookFeaturesAudio + kSCHAppBookFeaturesSample,
    kSCHAppBookFeaturesStoryInteractionsAudioSample = kSCHAppBookFeaturesStoryInteractions | kSCHAppBookFeaturesAudio | kSCHAppBookFeaturesSample
} SCHAppBookFeaturesFeatures;


@interface SCHAppBookFeatures : NSObject

@property (nonatomic, readonly) SCHAppBookFeaturesFeatures features;
@property (nonatomic, readonly) BOOL hasStoryInteractions;
@property (nonatomic, readonly) BOOL hasAudio;
@property (nonatomic, readonly) BOOL isSample;

- (id)initWithStoryInteractions:(BOOL)storyInteractions
                          audio:(BOOL)audio
                         sample:(BOOL)sample;

@end
