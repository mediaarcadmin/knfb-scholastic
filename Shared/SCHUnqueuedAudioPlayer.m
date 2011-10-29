//
//  SCHUnqueuedAudioPlayer.m
//  Scholastic
//
//  Created by Neil Gall on 28/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHUnqueuedAudioPlayer.h"

static SCHUnqueuedAudioPlayer *sharedAudioPlayer = nil;

@interface SCHUnqueuedAudioPlayer ()
@property (nonatomic, retain) NSMutableSet *activePlayers;
@end

@implementation SCHUnqueuedAudioPlayer

@synthesize activePlayers;

+ (SCHUnqueuedAudioPlayer *)sharedAudioPlayer
{
    if (sharedAudioPlayer == nil) {
        @synchronized(self) {
            if (sharedAudioPlayer == nil) {
                sharedAudioPlayer = [[SCHUnqueuedAudioPlayer alloc] init];
            }
        }
    }
    return sharedAudioPlayer;
}

- (void)dealloc
{
    [self stopAll];
    [activePlayers release], activePlayers = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        self.activePlayers = [NSMutableSet set];
    }
    return self;
}

- (void)playAudioAtPath:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfMappedFile:path];
    if (!data) {
        NSLog(@"failed to load audio data from %@", path);
        return;
    }
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (!player) {
        NSLog(@"failed to create AVAudioPlayer with %@: %@", path, error);
        return;
    }
    
    player.delegate = self;
    [self.activePlayers addObject:player];
    [player play];
    [player release];
}

- (void)playAudioFromMainBundle:(NSString *)filename
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@""];
    if (path) {
        [self playAudioAtPath:path];
    } else {
        NSLog(@"failed to find %@ in main bundle", filename);
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSAssert([NSThread isMainThread], @"expect delegate calls on main thread");
    [self.activePlayers removeObject:player];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSAssert([NSThread isMainThread], @"expect delegate calls on main thread");
    NSLog(@"audio player error: %@", error);
    [self.activePlayers removeObject:player];
}

- (void)stopAll
{
    [self.activePlayers makeObjectsPerformSelector:@selector(pause)];
    [self.activePlayers removeAllObjects];
}

@end
