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
    [paginator release], paginator = nil;
    [bookTitle release], bookTitle = nil;
    
    if (self.bookCheckedOut) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];
    }
    
	[super dealloc];
}

- (void) updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyToRead];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    
    [self endOperation];
}

- (void) updateBookWithFailure
{
    [self endOperation];
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
        self.bookCheckedOut = YES;
        
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
    
    NSLog(@"Pagination of book %@ took %ld seconds", self.bookTitle, (long)round(CFAbsoluteTimeGetCurrent() - self.startTime));
    
    [self updateBookWithSuccess];
}

- (void)paginationProgress:(NSNotification *)notification
{
	//self.percentageComplete = percentagePaginated;
    NSLog(@"Book %@ pagination progress: %f", [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn].Title, [[[notification userInfo] objectForKey:EucBookPaginatorNotificationPercentagePaginatedKey] floatValue]);
}


@end
