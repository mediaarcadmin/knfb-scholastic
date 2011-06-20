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
}

- (void)tearDown
{
    [queuedAudioPlayer release];
}

- (void)testClassSubstitution
{
    NSData *data = [NSData data];
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data; }
                               synchronizedStartBlock:nil
                                 synchronizedEndBlock:nil];
    DummyAVAudioPlayer *dummy = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy.data, data, @"player not initialised by enqueue");
    STAssertEquals(dummy.delegate, queuedAudioPlayer, @"player delegate not set");
}

- (void)testPlaySingleItem
{
    NSData *data = [NSData data];
    __block BOOL started = NO;
    __block BOOL ended = NO;
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data; }
                               synchronizedStartBlock:^{ started = YES; }
                                 synchronizedEndBlock:^{ ended = YES; }];

    DummyAVAudioPlayer *dummy = [DummyAVAudioPlayer lastNewInstance];
    STAssertTrue(dummy.playing, @"first enqueued audio should play immediately");
    STAssertTrue(started, @"start block should be called");
    STAssertFalse(ended, @"end block should not be called until playing finished");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy successfully:YES];

    STAssertTrue(ended, @"end block should be called after playing finished");
}

- (void)testPlayMultipleItems
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    __block int started = 0;
    __block int ended = 0;
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ started |= 1<<i; }
                                     synchronizedEndBlock:^{ ended |= 1<<i; }];
    }
    
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertEquals(started, 1, @"first start block should be called");
    STAssertEquals(ended, 0, @"first end block should not be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    STAssertEquals(ended, 1, @"first end block should be called");
    
    DummyAVAudioPlayer *dummy2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertEquals(started, 3, @"second start block should be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    STAssertEquals(ended, 3, @"second end block should be called");

    DummyAVAudioPlayer *dummy3 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(dummy1 == dummy3, @"new player should be created");
    STAssertFalse(dummy2 == dummy3, @"new player should be created");
    STAssertEquals(dummy3.data, [data objectAtIndex:2], @"dummy3 should have third data");
    STAssertTrue(dummy3.playing, @"new player should be playing");
    STAssertEquals(started, 7, @"third start block should be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy3 successfully:YES];
    STAssertEquals(ended, 7, @"third end block should be called");
}

- (void)testCancel
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    __block int started = 0;
    __block int ended = 0;
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ started |= 1<<i; }
                                     synchronizedEndBlock:^{ ended |= 1<<i; }];
    }
    
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertEquals(started, 1, @"first start block should be called");
    STAssertEquals(ended, 0, @"first end block should not be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    STAssertEquals(ended, 1, @"first end block should be called");
    
    DummyAVAudioPlayer *dummy2 = [[DummyAVAudioPlayer lastNewInstance] retain];
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertEquals(started, 3, @"second start block should be called");
    
    [queuedAudioPlayer cancel];
    STAssertFalse(dummy2.playing, @"dummy2 should have been stopped");
    STAssertEquals(ended, 1, @"second end block shold not be called");
    STAssertEquals(started, 3, @"third start block should not be called");
    STAssertEquals([DummyAVAudioPlayer lastNewInstance], dummy2, @"no new player should be created");
    [dummy2 release];
}

- (void)testCancelRaceWithFinish
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    __block int started = 0;
    __block int ended = 0;
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ started |= 1<<i; }
                                     synchronizedEndBlock:^{ ended |= 1<<i; }];
    }
    
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertEquals(started, 1, @"first start block should be called");
    STAssertEquals(ended, 0, @"first end block should not be called");
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy1 successfully:YES];
    STAssertEquals(ended, 1, @"first end block should be called");
    
    DummyAVAudioPlayer *dummy2 = [[DummyAVAudioPlayer lastNewInstance] retain];
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertEquals(started, 3, @"second start block should be called");

    // we invoke cancel but the player still invokes its delegate didFinishPlaying 
    [queuedAudioPlayer cancel];
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    
    STAssertFalse(dummy2.playing, @"dummy2 should have been stopped");
    STAssertEquals(ended, 1, @"second end block shold not be called");
    STAssertEquals(started, 3, @"third start block should not be called");
    STAssertEquals([DummyAVAudioPlayer lastNewInstance], dummy2, @"no new player should be created");
    [dummy2 release];    
}

- (void)testCancelAndReenqueue
{
    NSArray *data = [NSArray arrayWithObjects:[NSData data], [NSData data], [NSData data], nil];
    __block int started = 0;
    __block int ended = 0;
    
    for (NSInteger i = 0; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ started |= 1<<i; }
                                     synchronizedEndBlock:^{ ended |= 1<<i; }];
    }
    
    DummyAVAudioPlayer *dummy1 = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(dummy1.data, [data objectAtIndex:0], @"dummy1 should have first data");
    STAssertTrue(dummy1.playing, @"dummy1 should be playing");
    STAssertEquals(started, 1, @"first start block should be called");

    [queuedAudioPlayer cancel];
    
    __block int started2 = 0;
    __block int ended2 = 0;
    for (NSInteger i = 1; i < [data count]; ++i) {
        [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return [data objectAtIndex:i]; }
                                   synchronizedStartBlock:^{ started2 |= 1<<i; }
                                     synchronizedEndBlock:^{ ended2 |= 1<<i; }];
    }
    
    DummyAVAudioPlayer *dummy2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(dummy1 == dummy2, @"new player should be created");
    STAssertEquals(dummy2.data, [data objectAtIndex:1], @"dummy2 should have second data");
    STAssertTrue(dummy2.playing, @"new player should be playing");
    STAssertEquals(started, 1, @"original items should not be started");
    STAssertEquals(started2, 2, @"new item should be started");

    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)dummy2 successfully:YES];
    
    DummyAVAudioPlayer *dummy3 = [DummyAVAudioPlayer lastNewInstance];
    STAssertTrue(dummy3.playing, @"dummy3 should have been started");
    STAssertEquals(started, 1, @"original items should not be started");
    STAssertEquals(started2, 6, @"new blocks should be started");
}

- (void)testWithRealDataPath
{
    NSString *path = [[NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"] pathForResource:@"sfx_scratch" ofType:@"mp3"];
    NSData * (^fetchBlock)(void) = ^NSData*(void) {
        return [NSData dataWithContentsOfMappedFile:path];
    };
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock
                               synchronizedStartBlock:nil
                                 synchronizedEndBlock:nil];
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock
                               synchronizedStartBlock:nil
                                 synchronizedEndBlock:nil];
    
    DummyAVAudioPlayer *player = [DummyAVAudioPlayer lastNewInstance];
    STAssertNotNil(player.data, @"player should have data");
    STAssertEquals([player.data length], 9647U, @"player data should be correct length");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:YES];
    
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
    __block int started = 0;
    __block int ended = 0;
    
    [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data1; }
                               synchronizedStartBlock:^{ started |= 1; }
                                 synchronizedEndBlock:^{
                                     ended |= 1;
                                     [queuedAudioPlayer cancel];
                                     [queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData *(void) { return data2; }
                                                                synchronizedStartBlock:^{ started |= 2; }
                                                                  synchronizedEndBlock:^{ ended |= 2; }];
                                 }];
    DummyAVAudioPlayer *player = [DummyAVAudioPlayer lastNewInstance];
    STAssertEquals(started, 1, @"first block should be started");
    STAssertEquals(player.data, data1, @"first player data incorrect");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:YES];
    
    STAssertEquals(ended, 1, @"first block should be ended");
    STAssertEquals(started, 3, @"second block should be started");
    
    DummyAVAudioPlayer *player2 = [DummyAVAudioPlayer lastNewInstance];
    STAssertFalse(player == player2, @"must have new player");
    STAssertEquals(player2.data, data2, @"second player data incorrect");
    
    [queuedAudioPlayer audioPlayerDidFinishPlaying:(AVAudioPlayer *)player2 successfully:YES];

    STAssertEquals(ended, 3, @"second block should be ended");
}

@end
