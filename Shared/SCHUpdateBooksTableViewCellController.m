//
//  SCHUpdateBooksTableViewCellController.m
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUpdateBooksTableViewCellController.h"
#import "SCHUpdateBooksTableViewCell.h"
#import "SCHCheckbox.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHProcessingManager.h"

NSString * const kSCHBookUpdatedSuccessfullyNotification = @"book-updated-successfully";

@interface SCHUpdateBooksTableViewCellController ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;
@property (nonatomic, assign) NSInteger index;

- (SCHAppBook *)book;
- (BOOL)spinnerStateForProcessingState:(SCHBookCurrentProcessingState)state;

@end

@implementation SCHUpdateBooksTableViewCellController

@synthesize cell;
@synthesize bookEnabledForUpdate;
@synthesize managedObjectContext;
@synthesize bookIdentifier;
@synthesize index;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [cell release], cell = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [bookIdentifier release], bookIdentifier = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        managedObjectContext = [moc retain];
        bookIdentifier = [identifier retain];
        bookEnabledForUpdate = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdateBookState:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
        
        static NSInteger maxIndex = 0;
        self.index = maxIndex++;
    }
    return self;
}

- (SCHAppBook *)book
{
    return [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
}

- (void)setCell:(SCHUpdateBooksTableViewCell *)newCell
{
    if (!newCell) {
        [cell release], cell = nil;
        return;
    }

    SCHUpdateBooksTableViewCell *oldCell = cell;
    cell = [newCell retain];
    [oldCell release];
            
    SCHAppBook *book = [self book];
    [cell bookTitleLabel].text = book.Title;
    [cell enabledForUpdateCheckbox].selected = self.bookEnabledForUpdate;
    [cell enableSpinner:[self spinnerStateForProcessingState:[book processingState]]];
    
    cell.onCheckboxUpdate = ^(BOOL enable) {
        self.bookEnabledForUpdate = enable;
        NSLog(@"%@ update=%d", self.bookIdentifier, self.bookEnabledForUpdate);
    };
}

- (BOOL)spinnerStateForProcessingState:(SCHBookCurrentProcessingState)state
{
    switch (state) {
        case SCHBookProcessingStateDownloadStarted:
        case SCHBookProcessingStateReadyForAudioInfoParsing:
        case SCHBookProcessingStateReadyForBookFileDownload:
        case SCHBookProcessingStateReadyForLicenseAcquisition:
        case SCHBookProcessingStateReadyForPagination:
        case SCHBookProcessingStateReadyForRightsParsing:
        case SCHBookProcessingStateReadyForSmartZoomPreParse:
        case SCHBookProcessingStateReadyForTextFlowPreParse:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - Notifications

- (void)didUpdateBookState:(NSNotification *)note
{
    if ([[[note userInfo] objectForKey:@"bookIdentifier"] isEqual:self.bookIdentifier]) {
        SCHAppBook *book = [self book];
        [self.cell enableSpinner:[self spinnerStateForProcessingState:[book processingState]]];

        if (![book diskVersionOutOfDate]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookUpdatedSuccessfullyNotification object:self];
        }
    }
}

#pragma mark - Actions

- (void)enableForUpdateChanged:(SCHCheckbox *)sender
{
}

- (void)startUpdateIfEnabled
{
    if (self.bookEnabledForUpdate) {
        SCHAppBook *book = [self book];
        [book setForcedProcessing:YES];
        [book setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
        [[SCHProcessingManager sharedProcessingManager] userSelectedBookWithIdentifier:[book bookIdentifier]];
        [self.cell enableSpinner:[self spinnerStateForProcessingState:[book processingState]]];
    }
}

@end
