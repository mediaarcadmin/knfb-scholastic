//
//  SCHDictionaryDownloadManagerTests.m
//  Scholastic
//
//  Created by Neil Gall on 26/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CoreData/CoreData.h>

#import "SCHTestFixtureWithCoreDataStack.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHAppDictionaryState.h"
#import "SCHAppDictionaryManifestEntry.h"
#import "SCHDictionaryOperation.h"

#pragma mark - Dummy implementations of operation classes

@class SCHDummyOperation;
static void setLastCreatedOperation(SCHDummyOperation *operation);

@interface SCHDummyOperation : SCHDictionaryOperation
@property dispatch_semaphore_t sem;
@end

@implementation SCHDummyOperation

@synthesize sem;

- (id)init
{
    if ((self = [super init])) {
        setLastCreatedOperation(self);
        sem = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(sem), sem = NULL;
    [super dealloc];
}

- (void)main
{
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)allowToExit
{
    dispatch_semaphore_signal(sem);
}

@end

static SCHDummyOperation *lastCreatedOperation;
static void setLastCreatedOperation(SCHDummyOperation *op)
{
    lastCreatedOperation = [op retain];
}

@interface SCHHelpVideoManifestOperation : SCHDummyOperation
@end
@implementation SCHHelpVideoManifestOperation
@end

@interface SCHHelpVideoFileDownloadOperation : SCHDummyOperation
@property (nonatomic, retain) SCHHelpVideoManifest *videoManifest;
@end

@implementation SCHHelpVideoFileDownloadOperation

@synthesize videoManifest;

- (void)dealloc
{
    [videoManifest release], videoManifest = nil;
    [super dealloc];
}

@end

@interface SCHDictionaryManifestOperation : SCHDummyOperation
@end
@implementation SCHDictionaryManifestOperation
@end

@interface SCHDictionaryFileDownloadOperation : SCHDummyOperation
@property (nonatomic, retain) SCHDictionaryManifestEntry *manifestEntry;
@end

@implementation SCHDictionaryFileDownloadOperation

@synthesize manifestEntry;

- (void)dealloc
{
    [manifestEntry release], manifestEntry = nil;
    [super dealloc];
}

@end

@interface SCHDictionaryFileUnzipOperation : SCHDummyOperation
@end
@implementation SCHDictionaryFileUnzipOperation
@end

@interface SCHDictionaryParseOperation : SCHDummyOperation
@property (nonatomic, retain) SCHDictionaryManifestEntry *manifestEntry;
@end

@implementation SCHDictionaryParseOperation

@synthesize manifestEntry;

- (void)dealloc
{
    [manifestEntry release], manifestEntry = nil;
    [super dealloc];
}

@end

static NSString * const kSCHCoreDataHelperDictionaryStoreConfiguration = @"Dictionary";

@interface SCHDictionaryDownloadManagerTests : SenTestCase {
    SCHTestFixtureWithCoreDataStack *fixture;
    SCHDictionaryDownloadManager *dictionaryDownloadManager;
}
@end

@implementation SCHDictionaryDownloadManagerTests

- (void)setUp
{
    fixture = [[SCHTestFixtureWithCoreDataStack alloc] initWithPersistentStoreConfiguration:kSCHCoreDataHelperDictionaryStoreConfiguration];
    dictionaryDownloadManager = [[SCHDictionaryDownloadManager alloc] init];
    dictionaryDownloadManager.mainThreadManagedObjectContext = fixture.managedObjectContext;
    dictionaryDownloadManager.persistentStoreCoordinator = fixture.persistentStoreCoordinator;
    
    lastCreatedOperation = nil;
}

- (void)tearDown
{
    [dictionaryDownloadManager release], dictionaryDownloadManager = nil;
    [fixture release], fixture = nil;
    [lastCreatedOperation release], lastCreatedOperation = nil;
}

- (void)processDictionary
{
    [dictionaryDownloadManager performSelector:@selector(processDictionary)];
}

- (void)cancelLastCreatedOperation
{
    lastCreatedOperation.notCancelledCompletionBlock = nil;
    [lastCreatedOperation allowToExit];
    [lastCreatedOperation waitUntilFinished];
    [lastCreatedOperation release], lastCreatedOperation = nil;
}

- (void)finishLastCreatedOperation:(SCHDictionaryProcessingState)newState
{
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:newState];
    
    // to maintain the synchronous test flow, we have to pull out the operation's completion
    // block and invoke it synchronously on the main thread
    dispatch_block_t completionBlock = Block_copy(lastCreatedOperation.notCancelledCompletionBlock);
    lastCreatedOperation.notCancelledCompletionBlock = nil;
    
    [lastCreatedOperation allowToExit];
    [lastCreatedOperation waitUntilFinished];
    [lastCreatedOperation release], lastCreatedOperation = nil;
    
    if (completionBlock) {
        completionBlock();
        Block_release(completionBlock);
    }
}

- (void)insertManifestEntryInDatabaseWithFromVersion:(NSString *)fromVersion
                                           toVersion:(NSString *)toVersion
                                                 url:(NSString *)url
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"SCHAppDictionaryState"];
    NSError *error = nil;
    NSArray *results = [fixture.managedObjectContext executeFetchRequest:fetch error:&error];
    STAssertTrue([results count] == 1, @"must find a SCHAppDictionaryState in database");
    SCHAppDictionaryState *state = [[results objectAtIndex:0] retain];
    [fetch release];
    
    SCHAppDictionaryManifestEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:@"SCHAppDictionaryManifestEntry"
                                                                         inManagedObjectContext:fixture.managedObjectContext];
    entry.fromVersion = fromVersion;
    entry.toVersion = toVersion;
    entry.url = url;
    state.appDictionaryManifestEntry = entry;

    if (![fixture.managedObjectContext save:&error]) {
        STFail(@"save failed: %@", error);
    }
    [state release];
}


#pragma mark - Tests

- (void)testVideoDownloadStateMachineFlow
{
    STAssertEquals([dictionaryDownloadManager dictionaryProcessingState], SCHDictionaryProcessingStateHelpVideoManifest, @"initial state should be HelpVideoManifest");
    
    [self processDictionary];
    STAssertNotNil(lastCreatedOperation, @"processing from initial state should have created an operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHHelpVideoManifestOperation class]], @"processing from initial state should have created SCHHelpVideoManifestOperation");

    // simulate completion of the help manifest operation
    SCHHelpVideoManifest *helpVideoManifest = [[SCHHelpVideoManifest alloc] init];
    dictionaryDownloadManager.helpVideoManifest = helpVideoManifest;
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateDownloadingHelpVideos];

    STAssertNotNil(lastCreatedOperation, @"completion of HelpManifestOperation should have created a new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHHelpVideoFileDownloadOperation class]], @"should have created SCHHelpVideoFileDownloadOperation");
    STAssertEquals([(SCHHelpVideoFileDownloadOperation *)lastCreatedOperation videoManifest], helpVideoManifest, @"SCHHelpVideoFileDownloadOperation should be initialised with videoManifest");

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsManifest];

    [self cancelLastCreatedOperation];
    [helpVideoManifest release];
}

- (void)testVideoManifestErrorState
{
    [self processDictionary];
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHHelpVideoManifestOperation class]], @"processing from initial state should have created SCHHelpVideoManifestOperation");

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateError];
    STAssertNil(lastCreatedOperation, @"processing should end with error state");
}

- (void)testVideoDownloadIdleState:(SCHDictionaryProcessingState)state
{
    SCHHelpVideoManifest *helpVideoManifest = [[SCHHelpVideoManifest alloc] init];
    dictionaryDownloadManager.helpVideoManifest = helpVideoManifest;
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDownloadingHelpVideos];
    [self processDictionary];
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHHelpVideoFileDownloadOperation class]], @"should have created SCHHelpVideoFileDownloadOperation: %@", lastCreatedOperation);

    [self finishLastCreatedOperation:state];
    STAssertNil(lastCreatedOperation, @"processing should end with error state");
}

- (void)testVideoDownloadErrorState
{
    [self testVideoDownloadIdleState:SCHDictionaryProcessingStateError];
}

- (void)testVideoDownloadUserSetupState
{
    [self testVideoDownloadIdleState:SCHDictionaryProcessingStateUserSetup];
}

- (void)testVideoDownloadUserDeclinedState
{
    [self testVideoDownloadIdleState:SCHDictionaryProcessingStateUserDeclined];
}

- (void)testDictionaryManifestNoUpdates
{
    dictionaryDownloadManager.dictionaryVersion = @"1.0";
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    [self processDictionary];
    
    STAssertNotNil(lastCreatedOperation, @"processing from NeedsManifest state should have created a new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryManifestOperation class]], @"should have created SCHDictionaryManifestOperation");
    
    SCHDictionaryManifestEntry *manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry.toVersion = @"1.0";
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObject:manifestEntry];
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];
    
    STAssertNil(lastCreatedOperation, @"finishing SCHDictionaryManifestOperation with no updates should end processing");
    STAssertEquals([dictionaryDownloadManager dictionaryProcessingState], SCHDictionaryProcessingStateReady, @"should be in dictionary ready state");
}

- (void)testDictionaryManifestNoCurrentDictionary
{
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    [self processDictionary];
    
    STAssertNotNil(lastCreatedOperation, @"processing from NeedsManifest state should have created a new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryManifestOperation class]], @"should have created SCHDictionaryManifestOperation");
    
    SCHDictionaryManifestEntry *manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry.toVersion = @"1.0";
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObject:manifestEntry];
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];

    STAssertNotNil(lastCreatedOperation, @"finishing SCHDictionaryManifestOperation with no previous dictionary should create an operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry");
    
    [self cancelLastCreatedOperation];
    [manifestEntry release];
}

- (void)testDictionaryManifestNewDictionaryVersion
{
    dictionaryDownloadManager.dictionaryVersion = @"1.0";
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    [self processDictionary];
    
    STAssertNotNil(lastCreatedOperation, @"processing from NeedsManifest state should have created a new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryManifestOperation class]], @"should have created SCHDictionaryManifestOperation");
    
    SCHDictionaryManifestEntry *manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry.toVersion = @"1.1";
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObject:manifestEntry];
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];
    
    STAssertNotNil(lastCreatedOperation, @"finishing SCHDictionaryManifestOperation with new dictionary version should create an operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry");
    
    [self cancelLastCreatedOperation];
    [manifestEntry release];
}

- (void)testDictionaryManifestError
{
    dictionaryDownloadManager.dictionaryVersion = @"1.0";
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    [self processDictionary];
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryManifestOperation class]], @"should have created SCHDictionaryManifestOperation");

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateError];
    STAssertNil(lastCreatedOperation, @"manifest error should end processing");
}

- (void)testDictionaryDownloadNotEnoughFreeSpace
{
    SCHDictionaryManifestEntry *manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry.toVersion = @"1.1";
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObject:manifestEntry];
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsDownload];
    [self processDictionary];
    
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry");
    
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNotEnoughFreeSpace];
    STAssertNil(lastCreatedOperation, @"notEnoughFreeSpace should end processing");
}

- (void)testResumeFromDownloadState
{
    dictionaryDownloadManager.dictionaryVersion = @"1.0";
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsDownload];
    [self processDictionary];

    STAssertNotNil(lastCreatedOperation, @"processing in NeedsDownload state should create an operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryManifestOperation class]], @"should have created SCHDictionaryManifestOperation");
    
    SCHDictionaryManifestEntry *manifestEntry = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry.fromVersion = @"1.0";
    manifestEntry.toVersion = @"1.1";
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObject:manifestEntry];
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];

    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry");

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsUnzip];
    
    STAssertNotNil(lastCreatedOperation, @"finishing SCHDictionaryFileDownloadOperation should create new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileUnzipOperation class]], @"should have created SCHDictionaryFileUnzipOperation: %@", lastCreatedOperation);

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsParse];

    STAssertNotNil(lastCreatedOperation, @"finishing SCHDictionaryFileUnzipOperation should create new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryParseOperation class]], @"should have created SCHDictionaryFileParseOperation: %@", lastCreatedOperation);

    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];
    
    STAssertNil(lastCreatedOperation, @"finishing SCHDictionaryParseOperation with no updates should end processing");
    STAssertEquals([dictionaryDownloadManager dictionaryProcessingState], SCHDictionaryProcessingStateReady, @"should be in dictionary ready state");
}

- (void)testResumeFromUnzipState
{
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
    [self processDictionary];
    
    STAssertNotNil(lastCreatedOperation, @"launching in NeedsUnzip should create new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileUnzipOperation class]], @"should have created SCHDictionaryFileUnzipOperation: %@", lastCreatedOperation);
    
    [self cancelLastCreatedOperation];
}

- (void)testResumeFromParseState
{
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsParse];
    [self insertManifestEntryInDatabaseWithFromVersion:@"1.0" toVersion:@"1.1" url:nil];

    [self processDictionary];
    
    STAssertNotNil(lastCreatedOperation, @"launching in NeedsParse state should create new operation");
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryParseOperation class]], @"should have created SCHDictionaryFileParseOperation: %@", lastCreatedOperation);
    
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];
    
    STAssertNil(lastCreatedOperation, @"finishing SCHDictionaryParseOperation with no updates should end processing");
    STAssertEquals([dictionaryDownloadManager dictionaryProcessingState], SCHDictionaryProcessingStateReady, @"should be in dictionary ready state");
}

- (void)testMultipleManifestEntries
{
    SCHDictionaryManifestEntry *manifestEntry1 = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry1.fromVersion = @"1.0";
    manifestEntry1.toVersion = @"1.1";
    
    SCHDictionaryManifestEntry *manifestEntry2 = [[SCHDictionaryManifestEntry alloc] init];
    manifestEntry2.fromVersion = @"1.1";
    manifestEntry2.toVersion = @"1.2";
    
    dictionaryDownloadManager.manifestUpdates = [NSMutableArray arrayWithObjects:manifestEntry1, manifestEntry2, nil];
    [dictionaryDownloadManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateManifestVersionCheck];
    [self processDictionary];
    
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry1, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry1");
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsUnzip];
    
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileUnzipOperation class]], @"should have created SCHDictionaryFileUnzipOperation: %@", lastCreatedOperation);
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsParse];

    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryParseOperation class]], @"should have created SCHDictionaryFileParseOperation: %@", lastCreatedOperation);
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];

    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileDownloadOperation class]], @"should have created SCHDictionaryFileDownloadOperation: %@", lastCreatedOperation);
    STAssertEquals([(SCHDictionaryFileDownloadOperation *)lastCreatedOperation manifestEntry], manifestEntry2, @"SCHDictionaryFileDownloadOperation should have been initialised with manifestEntry2");
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsUnzip];
    
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryFileUnzipOperation class]], @"should have created SCHDictionaryFileUnzipOperation: %@", lastCreatedOperation);
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateNeedsParse];
    
    STAssertTrue([lastCreatedOperation isKindOfClass:[SCHDictionaryParseOperation class]], @"should have created SCHDictionaryFileParseOperation: %@", lastCreatedOperation);
    [self finishLastCreatedOperation:SCHDictionaryProcessingStateManifestVersionCheck];

    STAssertNil(lastCreatedOperation, @"finishing SCHDictionaryParseOperation with no updates should end processing");
    STAssertEquals([dictionaryDownloadManager dictionaryProcessingState], SCHDictionaryProcessingStateReady, @"should be in dictionary ready state");
    
    [manifestEntry1 release];
    [manifestEntry2 release];
}

@end

#pragma mark - Dummy implementations of other classes

@interface SCHAuthenticationManager : NSObject
@end
@implementation SCHAuthenticationManager
@end

@interface SCHDictionaryAccessManager : NSObject
@end

@implementation SCHDictionaryAccessManager

+ (SCHDictionaryAccessManager *)sharedAccessManager
{
    return nil;
}

@end

