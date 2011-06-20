//
//  DummyAVAudioPlayer.m
//  Scholastic
//
//  Created by Neil Gall on 18/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "DummyAVAudioPlayer.h"

@implementation DummyAVAudioPlayer

@synthesize data;
@synthesize delegate;
@synthesize playing;

static DummyAVAudioPlayer *lastNewInstance;

+ (id)alloc
{
    lastNewInstance = [super alloc];
    return lastNewInstance;
}

+ (DummyAVAudioPlayer *)lastNewInstance
{
    return lastNewInstance;
}

- (id)initWithData:(NSData *)aData error:(NSError **)error
{
    if ((self = [super init])) {
        self.data = aData;
        self.playing = NO;
    }
    return self;
}

- (void)play
{
    self.playing = YES;
}

- (void)pause
{
    self.playing = NO;
}

@end
