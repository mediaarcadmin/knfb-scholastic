//
//  SCHUpdateBooksTableViewCellController.m
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUpdateBooksTableViewCellController.h"
#import "SCHCheckbox.h"
#import "SCHGradientView.h"
#import "SCHAppBook.h"
#import "SCHProcessingManager.h"
#import "SCHBookIdentifier.h"

enum {
    kBookTitleLabelTag = 1,
    kBookTitleGradientTag = 2,
    kEnableForUpdateCheckboxTag = 3,
    kSpinnerTag = 4,
};

NSString * const kSCHBookUpdatedSuccessfullyNotification = @"book-updated-successfully";

@interface SCHUpdateBooksTableViewCellController ()

@property (nonatomic, retain) NSManagedObjectID *bookObjectID;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

- (SCHAppBook *)book;
- (void)updateSpinner;

@end

@implementation SCHUpdateBooksTableViewCellController

@synthesize cell;
@synthesize bookTitleLabel;
@synthesize enableForUpdateCheckbox;
@synthesize spinner;
@synthesize bookEnabledForUpdate;
@synthesize bookObjectID;
@synthesize managedObjectContext;
@synthesize bookIdentifier;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [cell release], cell = nil;
    [bookTitleLabel release], bookTitleLabel = nil;
    [enableForUpdateCheckbox release], enableForUpdateCheckbox = nil;
    [spinner release], spinner = nil;
    [bookObjectID release], bookObjectID = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [bookIdentifier release], bookIdentifier = nil;
    [super dealloc];
}

- (id)initWithBookObjectID:(NSManagedObjectID *)objectID inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        bookObjectID = [objectID retain];
        managedObjectContext = [moc retain];
        bookIdentifier = [[[self book] bookIdentifier] retain];
        bookEnabledForUpdate = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didUpdateBookState:)
                                                     name:@"SCHBookStateUpdate"
                                                   object:nil];
    }
    return self;
}

- (SCHAppBook *)book
{
    NSError *error = nil;
    SCHAppBook *book = (SCHAppBook *)[self.managedObjectContext existingObjectWithID:self.bookObjectID error:&error];
    if (!book) {
        NSLog(@"failed to fetch book with objectID: %@: %@", self.bookObjectID, error);
    }
    return book;
}

- (void)setCell:(UITableViewCell *)newCell
{
    if (cell != newCell) {
        [cell release];
        cell = [newCell retain];
        self.bookTitleLabel = (UILabel *)[cell viewWithTag:kBookTitleLabelTag];
        self.enableForUpdateCheckbox = (SCHCheckbox *)[cell viewWithTag:kEnableForUpdateCheckboxTag];
        self.spinner = (UIActivityIndicatorView *)[cell viewWithTag:kSpinnerTag];
        
        SCHGradientView *gradientView = (SCHGradientView *)[cell viewWithTag:kBookTitleGradientTag];
        CAGradientLayer *gradient = (CAGradientLayer *)[gradientView layer];
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                           (id)[[UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.] CGColor],
                           nil];
        gradient.locations = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
        gradient.startPoint = CGPointMake(0.0f, 0.5f);
        gradient.endPoint = CGPointMake(1.0f, 0.5f);
    }
    
    self.bookTitleLabel.text = [self book].Title;
    self.enableForUpdateCheckbox.selected = self.bookEnabledForUpdate;
    
    [self updateSpinner];
}

- (void)updateSpinner
{
    SCHAppBook *book = [self book];
    switch ([book processingState]) {
        case SCHBookProcessingStateDownloadStarted:
        case SCHBookProcessingStateReadyForAudioInfoParsing:
        case SCHBookProcessingStateReadyForBookFileDownload:
        case SCHBookProcessingStateReadyForLicenseAcquisition:
        case SCHBookProcessingStateReadyForPagination:
        case SCHBookProcessingStateReadyForRightsParsing:
        case SCHBookProcessingStateReadyForSmartZoomPreParse:
        case SCHBookProcessingStateReadyForTextFlowPreParse:
            [self.spinner startAnimating];
            break;
        default:
            [self.spinner stopAnimating];
            break;
    }
}

#pragma mark - Notifications

- (void)didUpdateBookState:(NSNotification *)note
{
    if ([[[note userInfo] objectForKey:@"bookIdentifier"] isEqual:self.bookIdentifier]) {
        [self updateSpinner];
        
        if (![[self book] diskVersionOutOfDate]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCHBookUpdatedSuccessfullyNotification object:self];
        }
    }
}

#pragma mark - Actions

- (void)enableForUpdateChanged:(id)sender
{
    self.bookEnabledForUpdate = self.enableForUpdateCheckbox.selected;
}

- (void)startUpdateIfEnabled
{
    if (self.bookEnabledForUpdate) {
        SCHAppBook *book = [self book];
        [book setForcedProcessing:YES];
        [book setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
        [[SCHProcessingManager sharedProcessingManager] userSelectedBookWithIdentifier:[book bookIdentifier]];
        [self.spinner startAnimating];
    }
}

@end
