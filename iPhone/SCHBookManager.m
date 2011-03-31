//
//  SCHBookManager.m
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookManager.h"
#import <pthread.h>
#import "SCHAppBook.h"
#import "SCHBookContents.h"
#import "KNFBFlowEucBook.h"

@interface SCHBookManager ()

@property (nonatomic, retain) NSMutableDictionary *cachedXPSProviders;
@property (nonatomic, retain) NSMutableDictionary *cachedEucBooks;
@property (nonatomic, retain) NSCountedSet *cachedXPSProviderCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedEucBookCheckoutCounts;
@property (nonatomic, retain) NSLock *threadSafeMutationLock;

- (BOOL)save:(NSError **)error;

@end


@implementation SCHBookManager

// the shared book manager object
static SCHBookManager *sSharedBookManager = nil;

// used to keep track of manage contexts
static pthread_key_t sManagedObjectContextKey;

// information from the feature compatibility plist
static NSDictionary *featureCompatibilityDictionary = nil;

// mutation count - additional check for thread safety
static int mutationCount = 0;


@synthesize cachedXPSProviders, cachedXPSProviderCheckoutCounts, cachedEucBooks, cachedEucBookCheckoutCounts, persistentStoreCoordinator, threadSafeMutationLock;

+ (SCHBookManager *)sharedBookManager
{
    // We don't need to bother being thread-safe in the initialisation here,
    // because the object can't be used until the NSPersistentStoreCoordinator 
    // is set, so that has to be all done on the main thread before other calls
    // are made anyway.
    if(!sSharedBookManager) {
        sSharedBookManager = [[self alloc] init];

        // By setting this, if we associate an object with sManagedObjectContextKey
        // using pthread_setspecific, CFRelease will be called on it before
        // the thread terminates.
        pthread_key_create(&sManagedObjectContextKey, (void (*)(void *))CFRelease);
		
		sSharedBookManager.threadSafeMutationLock = [[NSLock alloc] init];

    }
    return sSharedBookManager;
}

- (void)dealloc {
	self.threadSafeMutationLock = nil;
	[cachedXPSProviders release], cachedXPSProviders = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        // Initialization code.
		self.cachedXPSProviders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Compatibility Checking

+ (BOOL) checkAppCompatibilityForFeature: (NSString *) key version: (float) version
{
    if (!featureCompatibilityDictionary) {
        featureCompatibilityDictionary = 
		[[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] 
                                                     stringByAppendingPathComponent:@"ScholasticFeatureCompatibility.plist"]] retain];
    }
    
	NSNumber *dictVersion = [featureCompatibilityDictionary objectForKey:key];
	if (!dictVersion || [dictVersion floatValue] < version) {
		return NO;
	} else {
		return YES;
	}
}

+ (BOOL) appHasFeature: (NSString *) key
{
	BOOL hasFeature = NO;
	
	if ([featureCompatibilityDictionary objectForKey:key]) {
		hasFeature = YES;
	}
	
	return hasFeature;
}

#pragma mark -
#pragma mark Book Info vending

- (SCHAppBook *) bookWithIdentifier: (NSString *) isbn
{
	NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    SCHAppBook *book = nil;
    
    if (isbn) {
		
        NSEntityDescription *entityDescription = [NSEntityDescription 
                                                  entityForName:kSCHAppBook
                                                  inManagedObjectContext:context];
        NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                        fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                        substitutionVariables:[NSDictionary 
                                                               dictionaryWithObject:isbn 
                                                               forKey:kSCHAppBookCONTENT_IDENTIFIER]];
				
		NSError *error = nil;
		NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
		
		if (error) {
			NSLog(@"Error while fetching book item: %@", [error localizedDescription]);
		} else if (!results || [results count] != 1) {
			NSLog(@"Did not return expected single book for isbn %@.", isbn);
			NSLog(@"Results: %@", results);
		} else {
			book = (SCHAppBook *) [results objectAtIndex:0];
		}
    }
    else
	{
		NSLog(@"WARNING: book identifier is nil!");
	}
	
    if (book) {
        [context refreshObject:book mergeChanges:YES];
    }
    
    return book;
}

- (NSArray *)allBooksAsISBNs
{
    NSMutableArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:[self managedObjectContextForCurrentThread]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
	
	NSError *error = nil;				
	NSArray *allBooks = [[self managedObjectContextForCurrentThread] executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
    if ([allBooks count] > 0) {
        ret = [NSMutableArray arrayWithCapacity:[allBooks count]];
        for (SCHContentMetadataItem *contentMetadataItem in allBooks) {
            //[ret addObject:[[SCHBookManager sharedBookManager] bookWithIdentifier:contentMetadataItem.ContentIdentifier]];
            [ret addObject:contentMetadataItem.ContentIdentifier];
        }
    }
    
    return(ret);
}

#pragma mark -
#pragma mark Thread safe set/get book methods

- (void)threadSafeUpdateBookWithISBN: (NSString *) isbn setValue:(id)value forKey:(NSString *)key 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self.threadSafeMutationLock lock];
	
    {
        ++mutationCount;
        if(mutationCount != 1) {
			[NSException raise:@"SCHBookManagerMutationException" 
						format:@"Mutation count is greater than 1; multiple threads are accessing data in an unsafe manner."];
        }        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:isbn];
        if (nil == book) {
            NSLog(@"Failed to retrieve book in SCHBookManager threadSafeBookUpdateWithManagedObjectID:setValue:forKey:");
        } else {
            [book setValue:value forKey:key];
        }
        NSError *anError;
        if (![bookManager save:&anError]) {
            NSLog(@"[SCHBookManager setValue:%@ forKey:%@] Save failed with error: %@, %@", value, key, anError, [anError userInfo]);
        }
        --mutationCount;
    }

	[self.threadSafeMutationLock unlock];
    
    [pool drain];
}

- (id) threadSafeValueForBookWithISBN: (NSString *) isbn forKey: (NSString *) key
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
    if (nil == book) {
        NSLog(@"Failed to retrieve book in SCHBookManager threadSafeValueForBookWithISBN:forKey:");
        return nil;
    } else {
        return [book valueForKey:key];
    }
}

- (void)threadSafeUpdateBookWithISBN: (NSString *) isbn state: (SCHBookCurrentProcessingState) state 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[self.threadSafeMutationLock lock];
	
    {
        ++mutationCount;
        if(mutationCount != 1) {
			[NSException raise:@"SCHBookManagerMutationException" 
						format:@"Mutation count is greater than 1; multiple threads are accessing data in an unsafe manner."];
        }        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:isbn];
        if (nil == book) {
            NSLog(@"Failed to retrieve book in SCHBookManager threadSafeBookUpdateWithManagedObjectID:setValue:forKey:");
        } else {
            book.State = [NSNumber numberWithInt: (int) state];
        }
        NSError *anError;
        if (![bookManager save:&anError]) {
            NSLog(@"[SCHBookManager threadSafeUpdateBookWithISBN:%@ state:%@] Save failed with error: %@, %@", isbn, [book.State stringValue], anError, [anError userInfo]);
        }
        --mutationCount;
    }
	
	[self.threadSafeMutationLock unlock];
    
    [pool drain];
    
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStatusUpdate" object:self];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  isbn, @"isbn",
							  nil];
	
	//NSLog(@"percentage for %@: %2.2f%%", self.bookInfo.contentMetadata.Title, percentage * 100);
	
	[self performSelectorOnMainThread:@selector(statusNotification:) 
						   withObject:userInfo
						waitUntilDone:YES];

}

- (SCHBookCurrentProcessingState) processingStateForBookWithISBN: (NSString *) isbn
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
    if (nil == book) {
        NSLog(@"Failed to retrieve book in SCHBookManager processingStateForBookWithISBN:");
        return SCHBookProcessingStateError;
    } else {
        return [[book State] intValue];
    }
}


- (BOOL)save:(NSError **)error
{
    return [self.managedObjectContextForCurrentThread save:error];
}

#pragma mark -
#pragma mark Main Thread Notifications

- (void) statusNotification: (NSDictionary *) userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
}


#pragma mark -
#pragma mark Thread-specific MOC

// FIXME: move to SCHSyncManager?

- (NSManagedObjectContext *)managedObjectContextForCurrentThread
{
    NSManagedObjectContext *managedObjectContextForCurrentThread = (NSManagedObjectContext *)pthread_getspecific(sManagedObjectContextKey);
    if(!managedObjectContextForCurrentThread) {
        managedObjectContextForCurrentThread = [[NSManagedObjectContext alloc] init]; 
        managedObjectContextForCurrentThread.persistentStoreCoordinator = self.persistentStoreCoordinator; 
        self.managedObjectContextForCurrentThread = managedObjectContextForCurrentThread;
        [managedObjectContextForCurrentThread release];
    }
    return managedObjectContextForCurrentThread;
}

- (void)setManagedObjectContextForCurrentThread:(NSManagedObjectContext *)managedObjectContextForCurrentThread
{
    NSManagedObjectContext *oldManagedObjectContextForCurrentThread = (NSManagedObjectContext *)pthread_getspecific(sManagedObjectContextKey);
    if(oldManagedObjectContextForCurrentThread) {
        NSLog(@"Unexpectedly setting thread's managed object context on thread %@, which already has one set", [NSThread currentThread]);
        [oldManagedObjectContextForCurrentThread release];
    }
    
    // CFRelease will be called on the object before the thread terminates
    // (see comments in +sharedBookManager).
    pthread_setspecific(sManagedObjectContextKey, [managedObjectContextForCurrentThread retain]);
}




#pragma mark -
#pragma mark XPS Provider Check out/Check in

- (BITXPSProvider *)checkOutXPSProviderForBookIdentifier: (NSString *) isbn
{
	BITXPSProvider *ret = nil;
	
	//NSLog(@"Checking out book ID: %@", bookID);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        BITXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:isbn];
        if(previouslyCachedXPSProvider) {
            NSLog(@"Returning cached XPSProvider for book with ISBN %@", isbn);
            [self.cachedXPSProviderCheckoutCounts addObject:isbn];
            ret = previouslyCachedXPSProvider;
        } else {
			BITXPSProvider *xpsProvider = [[BITXPSProvider alloc] initWithISBN:isbn];
			if(xpsProvider) {
				NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
				if(!myCachedXPSProviderCheckoutCounts) {
					myCachedXPSProviderCheckoutCounts = [NSCountedSet set];
					self.cachedXPSProviderCheckoutCounts = myCachedXPSProviderCheckoutCounts;
				}
				
				[myCachedXPSProviders setObject:xpsProvider forKey:isbn];
				[myCachedXPSProviderCheckoutCounts addObject:isbn];
				ret = xpsProvider;
				[xpsProvider release];
			}
        }
    }
    
	[self.persistentStoreCoordinator unlock];
	
  //  NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookID], bookID);
    return ret;
	
}

- (void)checkInXPSProviderForBookIdentifier: (NSString *) isbn
{

	//NSLog(@"Checking in bookID: %@", bookInfo);
	
	NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
        NSUInteger count = [myCachedXPSProviderCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out XPSProvider");
        } else {
            [myCachedXPSProviderCheckoutCounts removeObject:isbn];
            if (count == 1) {
              //  NSLog(@"Releasing cached XPSProvider for book with ID %@", bookInfo);
                [myCachedXPSProviders removeObjectForKey:isbn];
                if(myCachedXPSProviderCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedXPSProviderCheckoutCounts = nil;
                }
            }
        }
       // NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookInfo], bookInfo);
		
    }
	
}

#pragma mark -
#pragma mark EucBook Check out/Check in

- (KNFBFlowEucBook *)checkOutEucBookForBookIdentifier: (NSString *) isbn
{
	KNFBFlowEucBook *ret = nil;
	
	//NSLog(@"Checking out book ID: %@", bookID);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        KNFBFlowEucBook *previouslyCachedEucBook = [myCachedEucBooks objectForKey:isbn];
        if(previouslyCachedEucBook) {
            NSLog(@"Returning cached EucBook for book with ISBN %@", isbn);
            [self.cachedEucBooks addObject:isbn];
            ret = previouslyCachedXPSProvider;
        } else {
			KNFBFlowEucBook *eucBook = [[KNFBFlowEucBook alloc] initWithISBN:isbn];
			if(eucBook) {
				NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
				if(!myCachedEucBookCheckoutCounts) {
					myCachedEucBookCheckoutCounts = [NSCountedSet set];
					self.cachedEucBookCheckoutCounts = myCachedEucBookCheckoutCounts;
				}
				
				[myCachedEucBooks setObject:eucBook forKey:isbn];
				[myCachedEucBookCheckoutCounts addObject:isbn];
				ret = eucBook;
				[eucBook release];
			}
        }
    }
    
	[self.persistentStoreCoordinator unlock];
	
    //  NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookID], bookID);
    return ret;
	
}

- (void)checkInEucBookForBookIdentifier: (NSString *) isbn
{
    
	//NSLog(@"Checking in bookID: %@", bookInfo);
	
	NSMutableDictionary *myCachedEucBooks = self.cachedXPSProviders;
    @synchronized(myCachedEucBooks) {
        NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
        NSUInteger count = [myCachedEucBookCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out EucBook");
        } else {
            [myCachedEucBookCheckoutCounts removeObject:isbn];
            if (count == 1) {
                //  NSLog(@"Releasing cached XPSProvider for book with ID %@", bookInfo);
                [myCachedEucBooks removeObjectForKey:isbn];
                if(myCachedEucBookCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedEucBookCheckoutCounts = nil;
                }
            }
        }
        // NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookInfo], bookInfo);
		
    }
	
}


@end
