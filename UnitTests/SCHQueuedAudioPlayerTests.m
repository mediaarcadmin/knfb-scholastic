//
//  SCHQueuedAudioPlayerTests.m
//  Scholastic
//
//  Created by Neil Gall on 18/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SCHQueuedAudioPlayer.h"
#import "DummyAVAudioPlayer.h"
#import "SCHSemaphoreGroup.h"

@interface TestableSCHQueuedAudioPlayer : SCHQueuedAudioPlayer {}
@end

@implementation TestableSCHQueuedAudioPlayer

- (AVAudioPlayer *)newAudioPlayerWithData:(NSData *)data
{
    return [[DummyAVAudioPlayer alloc] initWithData:data error:NULL];
}

@end

@interface SCHQueuedAudioPlayerTests : SenTestCase {
    SCHQueuedAudioPlayer *queuedAudioPlayer;
}
@end


@implementation SCHQueuedAudioPlayerTests

- (void)setUp
{
    queuedAudioPlayer = [[TestableSCHQueuedAudioPlayer alloc] init];
    queuedAudioPlayer.synchronizedBlockQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

- (void)tearDown
{
    [queuedAudioPlayer release];
}

- (void)testClassSubstitution
{
    NSData *data = [NSData data];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:1] autorelease];
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data; }
                               synchronizedStartBlock:^{ [started signal:0]; } 
                                 synchronizedEndBlock:nil];
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *dummy = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy.data, data, @"player not initialised by enqueue");
    STAssertEquals(dummy.delegate, queuedAudioPlayer, @"player delegate not set");
}

- (void)testPlaySingleItem
{
    NSData *data = [NSData data];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:1] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:1] autorelease];
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data; }
                               synchronizedStartBlock:^{ [started signal:0]; }
                                 synchronizedEndBlock:^{ [ended signal:0]; }];

    [started wait:0 withTimeout:1.0];
    
    DummyAVAudioPlayer *dummy = [DummyAVAudioPlayer lastNewInstance];
    STAssertTrue(dummy.playing, @"first enqueued audio should play immediately");
    STAssertTrue([started isSignalled:0], @"start block should be called");
    STAssertFalse([ended isSignalled:0], @"end block should not be called until playing finished");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy successfully:YES];
    [ended wait:0 withTimeout:1.0];

    STAssertTrue([ended isSignalled:0], @"end block should be called after playing finished");
}

- (void)testPlayMultipleItems
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];

    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ [started signal:i]; }
                                     synchronizedEndBlock:^{ [ended signal:i]; }];
    }
    
    [started wait:0 withTimeout:1.0];
    
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertTrue([started isSignalled:0], @"first start block should be called");
    STAssertFalse([ended isSignalled:0], @"first end block should not be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    [ended wait:0 withTimeout:1.0];
    
    STAssertTrue([ended isSignalled:0], @"first end block should be called");
    
    [started wait:1 withTimeout:1.0];
    DummyAVAudioPlayer *dummy2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertTrue([started isSignalled:1], @"second start block should be called");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    [ended wait:1 withTimeout:1.0];
    STAssertTrue([ended isSignalled:1], @"second end block should be called");

    [started wait:2 withTimeout:1.0];
    DummyAVAudioPlayer *dummy3 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(dummy1 == dummy3, @"new player should be created");
    STAssertFalse(dummy2 == dummy3, @"new player should be created");
    STAssertEquals(dummy3.data, [data objectAtIndex:2], @"dummy3 should have third data");
    STAssertTrue(dummy3.playing, @"new player should be playing");
    STAssertTrue([started isSignalled:2], @"third start block should be called");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy3 successfully:YES];
    [ended wait:2 withTimeout:1.0];
    
    STAssertTrue([ended isSignalled:2], @"third end block should be called");
}

- (void)testCancel
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ [started signal:i]; }
                                     synchronizedEndBlock:^{ [ended signal:i]; }];
    }
    
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];

    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertTrue([started isSignalled:0], @"first start block should be called");
    STAssertFalse([ended isSignalled:0], @"first end block should not be called");

    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    [ended wait:0 withTimeout:1.0];
    STAssertTrue([ended isSignalled:0], @"first end block should be called");
    
    [started wait:1 withTimeout:1.0];
    DummyAVAudioPlayer *dummy2 = [[DummyAVAudioPlayer lastNewInstance] retain];

    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertTrue([started isSignalled:1], @"second start block should be called");
    
    [queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
    [ended wait:1 withTimeout:1.0];
    
    STAssertFalse(dummy2.playing, @"dummy2 should have been stopped");
    STAssertFalse([ended isSignalled:1], @"second end block shold not be called");
    STAssertFalse([started isSignalled:2], @"third start block should not be called");
    STAssertEquals([DummyAVAudioPlayer lastNewInstance], dummy2, @"no new player should be created");
    [dummy2 release];
}

- (void)testCancelRaceWithFinish
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ [started signal:i]; }
                                     synchronizedEndBlock:^{ [ended signal:i]; }];
    }
    
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];

    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertTrue([started isSignalled:0], @"first start block should be called");
    STAssertFalse([ended isSignalled:0], @"first end block should not be called");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    [ended wait:0 withTimeout:1.0];
    STAssertTrue([ended isSignalled:0], @"first end block should be called");
    
    [started wait:1 withTimeout:1.0];
    DummyAVAudioPlayer *dummy2 = [[DummyAVAudioPlayer lastNewInstance] retain];
    
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertTrue([started isSignalled:1], @"second start block should be called");

    // we invoke cancel but the player still invokes its delegate didFinishPlaying 
    [queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    [ended wait:1 withTimeout:1.0];
    
    STAssertFalse(dummy2.playing, @"dummy2 should have been stopped");
    STAssertFalse([ended isSignalled:1], @"second end block shold not be called");
    STAssertFalse([started isSignalled:2], @"third start block should not be called");
    STAssertEquals([DummyAVAudioPlayer lastNewInstance], dummy2, @"no new player should be created");
    [dummy2 release];    
}

- (void)testCancelAndReenqueue
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ [started signal:i]; }
                                     synchronizedEndBlock:^{ [ended signal:i]; }];
    }
    
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertTrue([started isSignalled:0], @"first start block should be called");

    [queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
    [ended wait:0 withTimeout:1.0];
    
    SCHSemaphoreGroup *started2 = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    SCHSemaphoreGroup *ended2 = [[[SCHSemaphoreGroup alloc] initWithCount:[data count]] autorelease];
    for (NSInteger i = 1; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ [started2 signal:i]; }
                                     synchronizedEndBlock:^{ [ended2 signal:i]; }];
    }
    
    [started2 wait:1 withTimeout:1.0];
    DummyAVAudioPlayer *dummy2 = [DummyAVAudioPlayer lastNewInstance];
    
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertFalse([started isSignalled:1], @"original items should not be started");
    STAssertTrue([started2 isSignalled:1], @"new item should be started");

    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    [ended2 wait:1 withTimeout:1.0];

    [started2 wait:2 withTimeout:1.0];
    DummyAVAudioPlayer *dummy3 = [DummyAVAudioPlayer lastNewInstance];

    STAssertFalse(dummy3 == dummy1, @"new player should be created");
    STAssertFalse(dummy3 == dummy2, @"new player should be created");
    STAssertTrue(dummy3.playing, @"dummy3 should have been started");
    STAssertFalse([started isSignalled:1], @"original items should not be started");
    STAssertFalse([started isSignalled:2], @"original items should not be started");
    STAssertTrue([started2 isSignalled:2], @"new blocks should be started");
}

- (void)testWithRealDataPath
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"] pathForResource:@"sfx_scratch" ofType:@"mp3"];
    NSData * (^fetchBlock)(void) = ^NSData*(void) {
        return [NSData dataWithContentsOfMappedFile:path];
    };
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:2] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:2] autorelease];
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock
                               synchronizedStartBlock:^{ [started signal:0]; }
                                 synchronizedEndBlock:^{ [ended signal:0]; }];
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock
                               synchronizedStartBlock:^{ [started signal:1]; }
                                 synchronizedEndBlock:^{ [ended signal:1]; }];
    
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *player = [DummyAVAudioPlayer lastNewInstance];
    STAssertNotNil(player.data, @"player should have data");
    STAssertEquals([player.data length], 9647U, @"player data should be correct length");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:YES];

    [started wait:1 withTimeout:1.0];
    DummyAVAudioPlayer *player2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(player == player2, @"must have new player");
    STAssertNotNil(player2.data, @"player should have data");
    STAssertEquals([player2.data length], 9647U, @"player data should be correct length");
}

- (void)testChainedEnqueue
{
    // simulates original -playAudioAtPath interface in SCHStoryInteractionController
    NSData *data1 = [NSData data];
    NSData *data2 = [NSData data];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:2] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:2] autorelease];
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data1; }
                               synchronizedStartBlock:^{ [started signal:0]; }
                                 synchronizedEndBlock:^{
                                     [ended signal:0];
                                     [queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
                                     [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data2; }
                                                                synchronizedStartBlock:^{ [started signal:1]; }
                                                                  synchronizedEndBlock:^{ [ended signal:1]; }];
                                 }];
    
    [started wait:0 withTimeout:1.0];
    DummyAVAudioPlayer *player = [DummyAVAudioPlayer lastNewInstance];
    
    STAssertTrue([started isSignalled:0], @"first block should be started");
    STAssertEquals(player.data, data1, @"first player data incorrect");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:YES];
    [ended wait:0 withTimeout:1.0];
    STAssertTrue([ended isSignalled:0], @"first block should be ended");
    
    [started wait:1 withTimeout:1.0];
    STAssertTrue([started isSignalled:1], @"second block should be started");
    
    DummyAVAudioPlayer *player2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(player == player2, @"must have new player");
    STAssertEquals(player2.data, data2, @"second player data incorrect");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player2 successfully:YES];
    [ended wait:1 withTimeout:1.0];

    STAssertTrue([ended isSignalled:1], @"second block should be ended");
}

- (void)testReleasePlayerInEndBlock
{
    NSData *data = [NSData data];
    SCHSemaphoreGroup *started = [[[SCHSemaphoreGroup alloc] initWithCount:1] autorelease];
    SCHSemaphoreGroup *ended = [[[SCHSemaphoreGroup alloc] initWithCount:1] autorelease];
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data; }
                               synchronizedStartBlock:^{ [started signal:0]; }
                                 synchronizedEndBlock:^{ [queuedAudioPlayer release], queuedAudioPlayer = nil; [ended signal:0]; }];
    [started wait:0 withTimeout:1.0];
    STAssertTrue([started isSignalled:0], @"should have started automatically");
    
    DummyAVAudioPlayer *player = [DummyAVAudioPlayer lastNewInstance];
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:YES];
    [ended wait:0 withTimeout:1.0];
    
    STAssertTrue([ended isSignalled:0], @"should have ended cleanly");
    STAssertNil(queuedAudioPlayer, @"should have released player");
}

@end
