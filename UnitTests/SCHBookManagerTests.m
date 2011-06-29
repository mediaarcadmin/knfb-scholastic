//
//  SCHBookManagerTests.m
//  Scholastic
//
//  Created by Neil Gall on 28/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SCHTestClassWithCoreDataStack.h"
#import "SCHAppBook.h"
#import "SCHContentMetadataItem.h"
#import "SCHBookManager.h"

@interface SCHBookManagerTests : SCHTestClassWithCoreDataStack {
    SCHBookManager *bookManager;
    dispatch_queue_t bgQueue;
    dispatch_group_t bgGroup;
}
@end

@implementation SCHBookManagerTests

- (void)setUp
{
    [super setUp];
    
    bookManager = [SCHBookManager sharedBookManager];
    bookManager.persistentStoreCoordinator = self.persistentStoreCoordinator;

    bgGroup = dispatch_group_create();
    bgQueue = dispatch_queue_create("com.bitwink.unittests.bgqueue", 0);
    dispatch_set_target_queue(bgQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
}

- (void)tearDown
{
    [super tearDown];
    
    dispatch_release(bgQueue), bgQueue = NULL;
    dispatch_release(bgGroup), bgGroup = NULL;
}

- (void)save
{
    NSError *error = nil;
    STAssertTrue([self.managedObjectContext save:&error], @"failed to save: %@", error);
}

- (void)addBookWithIdentifier:(NSString *)identifier
{
    SCHContentMetadataItem *metadata = [NSEntityDescription insertNewObjectForEntityForName:kSCHContentMetadataItem
                                                                     inManagedObjectContext:self.managedObjectContext];
    metadata.ContentIdentifier = identifier;
    
    SCHAppBook *book = [NSEntityDescription insertNewObjectForEntityForName:kSCHAppBook
                                                     inManagedObjectContext:self.managedObjectContext];
    book.ContentMetadataItem = metadata;
    
    [self save];
}

- (void)testBookWithIdentifier
{
    [self addBookWithIdentifier:@"1234"];
    [self addBookWithIdentifier:@"2345"];
    
    SCHAppBook *book = [bookManager bookWithIdentifier:@"1234"];
    STAssertNotNil(book, @"book should be found");
    STAssertEqualObjects(book.ContentMetadataItem.ContentIdentifier, @"1234", @"incorrect book returned");

    SCHAppBook *book2 = [bookManager bookWithIdentifier:@"2345"];
    STAssertNotNil(book2, @"book should be found");
    STAssertEqualObjects(book2.ContentMetadataItem.ContentIdentifier, @"2345", @"incorrect book returned");
}

- (void)testThreadSafeUpdateKeyValue
{
    NSString *isbn = @"1234";
    [self addBookWithIdentifier:isbn];
    
    SCHAppBook *book = [bookManager bookWithIdentifier:isbn];
    book.XPSAuthor = @"Arthur C. Clarke";
    
    dispatch_group_async(bgGroup, bgQueue, ^{
        STAssertFalse(dispatch_get_current_queue() == dispatch_get_main_queue(), @"background operation must be off main thread");
        STAssertFalse([bookManager managedObjectContextForCurrentThread] == self.managedObjectContext, @"background thread must have own MOC");
        [bookManager threadSafeUpdateBookWithISBN:isbn setValue:@"Isaac Asimov" forKey:@"XPSAuthor"];
    });
    dispatch_group_wait(bgGroup, DISPATCH_TIME_FOREVER);
    
    STAssertEqualObjects(book.XPSAuthor, @"Isaac Asimov", @"book author should be updated");
}

- (void)testThreadSafeUpdateProcessingState
{
    NSString *isbn = @"1234";
    [self addBookWithIdentifier:isbn];
    
    SCHAppBook *book = [bookManager bookWithIdentifier:isbn];
    book.State = [NSNumber numberWithInt:SCHBookProcessingStateDownloadStarted];
    
    STAssertEquals([book.State intValue], SCHBookProcessingStateDownloadStarted, @"book state should be initialised");

    dispatch_group_async(bgGroup, bgQueue, ^{
        STAssertFalse(dispatch_get_current_queue() == dispatch_get_main_queue(), @"background operation must be off main thread");
        [bookManager threadSafeUpdateBookWithISBN:isbn state:SCHBookProcessingStateReadyToRead];
    });
    dispatch_group_wait(bgGroup, DISPATCH_TIME_FOREVER);
    
    STAssertEquals([book.State intValue], SCHBookProcessingStateReadyToRead, @"book state should be updated");
}

@end
