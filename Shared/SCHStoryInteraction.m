//
//  SCHStoryInteraction.m
//  StoryInteractions
//
//  Created by Neil Gall on 30/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"

// TODO: move this to KNFBXPSConstants submodule
NSString * const KNFBXPSStoryInteractionsDirectory = @"/Documents/1/Other/KNFB/Interactions/";

@implementation SCHStoryInteractionQuestion

@synthesize storyInteraction;
@synthesize questionIndex;

- (NSString *)audioPathForThatsRight
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_thatsright.mp3"];
}

- (NSString *)audioPathForTryAgain
{
    return [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:@"gen_tryagain.mp3"];
}

- (NSString *)storyInteractionCorrectAnswerSoundFilename
{
    if ([self.storyInteraction isOlderStoryInteraction]) {
        return @"sfx_ca_o.mp3";
    } else {
        return @"sfx_ca_y.mp3";
    }
}

- (NSString *)storyInteractionWrongAnswerSoundFilename
{
    if ([self.storyInteraction isOlderStoryInteraction]) {
        return @"sfx_wa_o.mp3";
    } else {
        return @"sfx_wa_y.mp3";
    }
}


@end

@implementation SCHStoryInteraction

@synthesize ID;
@synthesize documentPageNumber;
@synthesize position;

- (BOOL)isOlderStoryInteraction
{
    return NO;
}

- (NSString *)title
{
    // override in subclasses
    return nil;
}

- (NSString *)interactionViewTitle
{
    return [self title];
}

- (NSString *)storyInteractionButtonAppearingSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_siappears_o.mp3";
    } else {
        return @"sfx_siappears_y2B.mp3";
    }
}

- (NSString *)storyInteractionOpeningSoundFilename
{
    if ([self isOlderStoryInteraction]) {
        return @"sfx_siopen_o.mp3";
    } else {
        return @"sfx_siopen_y.mp3";
    }
}



@end
