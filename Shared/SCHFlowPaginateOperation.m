//
//  SCHFlowPaginateOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowPaginateOperation.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

#import <libEucalyptus/EucBUpeBook.h>
#import <libEucalyptus/EucBookPaginator.h>


@interface SCHFlowPaginateOperation ()

@property (nonatomic, retain) EucBookPaginator *paginator;
@property (nonatomic, copy) NSString *bookTitle;
@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) BOOL bookCheckedOut;

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

@implementation SCHFlowPaginateOperation

@synthesize paginator;
@synthesize bookTitle;
@synthesize startTime;
@synthesize bookCheckedOut;


- (void)dealloc {
	[super dealloc];
}

- (void) updateBookWithSuccess
{
    if (self.bookCheckedOut) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
    }
    
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyToRead];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void) updateBookWithFailure
{
    if (self.bookCheckedOut) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
    }
    
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void) beginOperation
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];

  //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *paginationPath = [[book cacheDirectory] stringByAppendingPathComponent:kSCHAppBookEucalyptusCacheDir];
    
//    if(self.forceReprocess) {
        // Best effort - ignore errors.
//        [[NSFileManager defaultManager] removeItemAtPath:paginationPath error:NULL];
//    }
    
    self.startTime = CFAbsoluteTimeGetCurrent();
    
    EucBUpeBook *eucBook = nil;
    // Create a EucBook for the paginator.
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        self.bookTitle = book.Title;
        
        NSLog(@"Paginating book %@", self.bookTitle);
        
        eucBook = [[[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:self.isbn] retain];
/*        BITXPSProvider *provider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:book.ContentIdentifier];

        if(eucBook) {
            [self setBookCheckedOut:YES];
            NSURL *coverURL = [NSURL URLWithString:book.BookCoverURL];
            if(coverURL) {
                NSLog(@"eucBook.coverURL: %@",coverURL);
                NSData *coverData = [provider coverThumbData];
                if(coverData) {
                    [coverData writeToFile:[self.cacheDirectory stringByAppendingPathComponent:BlioManifestCoverKey] atomically:NO];
                    
                    NSDictionary *manifestEntry = [NSMutableDictionary dictionary];
                    [manifestEntry setValue:BlioManifestEntryLocationFileSystem forKey:BlioManifestEntryLocationKey];
                    [manifestEntry setValue:BlioManifestCoverKey forKey:BlioManifestEntryPathKey];
                    [self setBookManifestValue:manifestEntry forKey:BlioManifestCoverKey];
                    NSMutableDictionary * noteInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                    [noteInfo setObject:self.bookID forKey:@"bookID"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:BlioProcessingReprocessCoverThumbnailNotification object:self userInfo:noteInfo];
                } else {
                    NSLog(@"Couldn't get data for cover in book.");
                }
            }
		}
        
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:book.ContentIdentifier];
        [pool drain];
    }
  */  
        if([eucBook paginationIsComplete] || eucBook == nil) {
            // This book is already fully paginated!
            NSLog(@"This book is already fully paginated!");
            [self updateBookWithSuccess];
        } else {
            eucBook.title = book.Title;
            eucBook.cacheDirectoryPath = [[book cacheDirectory] stringByAppendingPathComponent:kSCHAppBookEucalyptusCacheDir];
            
            BOOL isDirectory = YES;
            NSString *cannedPaginationPath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PageIndexes"] stringByAppendingPathComponent:[book.Title stringByAppendingPathExtension:@"libEucalyptusPageIndexes"]];    
            if([[NSFileManager defaultManager] fileExistsAtPath:cannedPaginationPath isDirectory:&isDirectory] && isDirectory) {       
                NSLog(@"Using pre-canned indexes for %@", book.Title);
                
                [[NSFileManager defaultManager] copyItemAtPath:cannedPaginationPath
                                                        toPath:paginationPath 
                                                         error:NULL];
                [self updateBookWithSuccess];
            } else {
                // Create the directory to store the pagination data if necessary.
                if(![[NSFileManager defaultManager] fileExistsAtPath:paginationPath isDirectory:&isDirectory] || !isDirectory) {
                    NSError *error = nil;
                    if(![[NSFileManager defaultManager] createDirectoryAtPath:paginationPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                        NSLog(@"Failed to create book cache directory in processing manager with error: %@, %@", error, [error userInfo]);
                    }
                }            
                
                // Actually set up the pagination!
                paginator = [[EucBookPaginator alloc] init];
                
                [[NSNotificationCenter defaultCenter] addObserver:self 
                                                         selector:@selector(paginationComplete:)
                                                             name:EucBookPaginatorCompleteNotification
                                                           object:paginator];
                [[NSNotificationCenter defaultCenter] addObserver:self 
                                                         selector:@selector(paginationProgress:)
                                                             name:EucBookBookPaginatorProgressNotification
                                                           object:paginator];
                
                
                [paginator paginateBookInBackground:eucBook saveImagesTo:nil];
            }
        }
        
        [eucBook release];
        [pool drain];
        
    }
    
}


- (void)paginationComplete:(NSNotification *)notification
{   
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];

    if(![book.LayoutPageEquivalentCount integerValue]) {
        // If we don't have a layout page length yet (because we have no layout document)
        // calculate smething sensible so that the bars that show comparable lengths
        // of books in the UI can look 'right'.
        
        NSDictionary *pageCounts = [[notification userInfo] objectForKey:EucBookPaginatorNotificationPageCountForPointSizeKey];
        NSInteger pageCount = [[pageCounts objectForKey:[NSNumber numberWithInteger:18]] integerValue];
        NSInteger layoutEquivalentPageCount = (NSInteger)round((double)pageCount / 0.34);
        [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn setValue:[NSNumber numberWithInt:layoutEquivalentPageCount] forKey:kSCHAppBookLayoutPageEquivalentCount];
        
        //        NSLog(@"Using layout equivalent page length of %ld for %@", layoutEquivalentPageCount, [self getBookValueForKey:@"title"]); 
    }
    
    CFAbsoluteTime elapsedTime = CFAbsoluteTimeGetCurrent() - self.startTime;
    NSLog(@"Pagination of book %@ took %ld seconds", self.bookTitle, (long)round(elapsedTime));
    
    [self updateBookWithSuccess];
}

- (void)paginationProgress:(NSNotification *)notification
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    NSDictionary *userInfo = [notification userInfo];
    CGFloat percentagePaginated = [[userInfo objectForKey:EucBookPaginatorNotificationPercentagePaginatedKey] floatValue];
	//self.percentageComplete = percentagePaginated;
    NSLog(@"Book %@ pagination progress: %f", book.Title, percentagePaginated);
}


@end
