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
#import "SCHTextFlow.h"
#import "SCHXPSProvider.h"
#import "SCHFlowEucBook.h"
#import "SCHTextFlowParagraphSource.h"
#import "SCHSmartZoomBlockSource.h"

@interface SCHBookManager ()

@property (nonatomic, retain) NSMutableDictionary *cachedXPSProviders;
@property (nonatomic, retain) NSMutableDictionary *cachedEucBooks;
@property (nonatomic, retain) NSMutableDictionary *cachedTextFlows;
@property (nonatomic, retain) NSMutableDictionary *cachedParagraphSources;
@property (nonatomic, retain) NSMutableDictionary *cachedBlockSources;
@property (nonatomic, retain) NSCountedSet *cachedXPSProviderCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedEucBookCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedTextFlowCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedParagraphSourceCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedBlockSourceCheckoutCounts;
@property (nonatomic, retain) NSLock *threadSafeMutationLock;

@property (nonatomic, retain) NSMutableDictionary *isbnManagedObjectCache;

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


@synthesize cachedXPSProviders;
@synthesize cachedXPSProviderCheckoutCounts;
@synthesize cachedEucBooks;
@synthesize cachedEucBookCheckoutCounts;
@synthesize cachedTextFlows;
@synthesize cachedParagraphSources;
@synthesize cachedBlockSources;
@synthesize cachedTextFlowCheckoutCounts;
@synthesize cachedParagraphSourceCheckoutCounts;
@synthesize cachedBlockSourceCheckoutCounts;
@synthesize persistentStoreCoordinator;
@synthesize threadSafeMutationLock;
@synthesize isbnManagedObjectCache;

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

- (id)init
{
    if ((self = [super init])) {
		cachedXPSProviders = [[NSMutableDictionary alloc] init];
		cachedEucBooks = [[NSMutableDictionary alloc] init];
		cachedTextFlows = [[NSMutableDictionary alloc] init];
        cachedParagraphSources = [[NSMutableDictionary alloc] init];
        cachedBlockSources = [[NSMutableDictionary alloc] init];
        isbnManagedObjectCache = [[NSMutableDictionary alloc] init];
    }
    return(self);
}

- (void)dealloc 
{
	[threadSafeMutationLock release], threadSafeMutationLock = nil;
	[cachedXPSProviders release], cachedXPSProviders = nil;
    [cachedEucBooks release], cachedEucBooks = nil;
    [cachedTextFlows release], cachedTextFlows = nil;
    [cachedParagraphSources release], cachedParagraphSources = nil;
    [cachedBlockSources release], cachedBlockSources = nil;
    [isbnManagedObjectCache release], isbnManagedObjectCache = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Compatibility Checking

+ (BOOL)checkAppCompatibilityForFeature:(NSString *)key version:(float)version
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

+ (BOOL)appHasFeature: (NSString *)key
{
	BOOL hasFeature = NO;
	
	if ([featureCompatibilityDictionary objectForKey:key]) {
		hasFeature = YES;
	}
	
	return(hasFeature);
}

#pragma mark -
#pragma mark Book Info vending

- (SCHAppBook *)bookWithIdentifier:(NSString *)isbn
{
	NSManagedObjectContext *context = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    SCHAppBook *book = nil;
    NSError *error = nil;
    
    if (isbn && context) {
        NSManagedObjectID *managedObjectID = [isbnManagedObjectCache objectForKey:isbn];
        if (managedObjectID == nil) {
            NSEntityDescription *entityDescription = [NSEntityDescription 
                                                      entityForName:kSCHAppBook
                                                      inManagedObjectContext:context];
            
            if (!entityDescription) {
                NSLog(@"WARNING: entity description is nil for %@", isbn);
            } else {
                NSFetchRequest *fetchRequest = [entityDescription.managedObjectModel 
                                                fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                                substitutionVariables:[NSDictionary 
                                                                       dictionaryWithObject:isbn 
                                                                       forKey:kSCHAppBookCONTENT_IDENTIFIER]];
                NSArray *bookArray = [context executeFetchRequest:fetchRequest error:&error];

                if ([bookArray count] > 0) {
                    book = (SCHAppBook *)[bookArray objectAtIndex:0];
                    [self.isbnManagedObjectCache setObject:book.objectID forKey:isbn];
                }
            }
        } else {
            book = (SCHAppBook *) [context existingObjectWithID:managedObjectID error:&error];
        }
    } else {
		NSLog(@"WARNING: book identifier is nil! request for %@", isbn);
	}
	
    if (error) {
        NSLog(@"Error while fetching book item: %@", [error localizedDescription]);
        
    } else if (book) {
        [context refreshObject:book mergeChanges:YES];
    }
    
    return(book);
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

- (void)threadSafeUpdateBookWithISBN:(NSString *)isbn setValue:(id)value forKey:(NSString *)key 
{
    
    if (!isbn || [isbn isEqual:[NSNull null]] ||
        !value || [value isEqual:[NSNull null]] ||
        !key || [key isEqual:[NSNull null]])
    {
        NSLog(@"Attempted to use null value in threadSafeUpdateBookWithISBN. ISBN: %@ value: %@ key: %@", isbn, value, key);
        return;
    }
                  
    
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

- (id)threadSafeValueForBookWithISBN:(NSString *)isbn forKey:(NSString *)key
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];
    if (nil == book) {
        NSLog(@"Failed to retrieve book in SCHBookManager threadSafeValueForBookWithISBN:forKey:");
        return nil;
    } else {
        return [book valueForKey:key];
    }
}

- (void)threadSafeUpdateBookWithISBN:(NSString *)isbn state:(SCHBookCurrentProcessingState)state 
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

- (SCHBookCurrentProcessingState)processingStateForBookWithISBN:(NSString *)isbn
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

- (void)statusNotification:(NSDictionary *)userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookStateUpdate" object:nil userInfo:userInfo];
}


#pragma mark -
#pragma mark Thread-specific MOC

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

- (SCHXPSProvider *)checkOutXPSProviderForBookIdentifier:(NSString *)isbn
{
	SCHXPSProvider *ret = nil;
	
	//NSLog(@"Checking out XPS for book: %@", isbn);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        SCHXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:isbn];
        if(previouslyCachedXPSProvider) {
            //NSLog(@"Returning cached XPSProvider for book with ISBN %@", isbn);
            [self.cachedXPSProviderCheckoutCounts addObject:isbn];
            ret = previouslyCachedXPSProvider;
        } else {
			SCHXPSProvider *xpsProvider = [[SCHXPSProvider alloc] initWithISBN:isbn];
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
	
    //NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:isbn], isbn);

    return(ret);
	
}

- (void)checkInXPSProviderForBookIdentifier:(NSString *)isbn
{

   // NSLog(@"Checking in XPS for book: %@", isbn);
	
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
       // NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:isbn], isbn);
		
    }
	
}

#pragma mark -
#pragma mark EucBook Check out/Check in

- (SCHFlowEucBook *)checkOutEucBookForBookIdentifier:(NSString *)isbn
{
	SCHFlowEucBook *ret = nil;
	
	//NSLog(@"Checking out EucBook for book: %@", isbn);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        SCHFlowEucBook *previouslyCachedEucBook = [myCachedEucBooks objectForKey:isbn];
        if(previouslyCachedEucBook) {
            NSLog(@"Returning cached EucBook for book with ISBN %@", isbn);
            [self.cachedEucBookCheckoutCounts addObject:isbn];
            ret = previouslyCachedEucBook;
        } else {
			SCHFlowEucBook *eucBook = [[SCHFlowEucBook alloc] initWithISBN:isbn];
			if(eucBook) {
				NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
				if(!myCachedEucBookCheckoutCounts) {
					myCachedEucBookCheckoutCounts = [NSCountedSet set];
					self.cachedEucBookCheckoutCounts = myCachedEucBookCheckoutCounts;
				}
				
				[myCachedEucBooks setObject:eucBook forKey:isbn];
				[myCachedEucBookCheckoutCounts addObject:isbn];
                [eucBook release];
				ret = eucBook;
			}
        }
    }
    
	[self.persistentStoreCoordinator unlock];
	
    return(ret);
}

- (void)checkInEucBookForBookIdentifier:(NSString *)isbn
{
    
	//NSLog(@"Checking in EucBook for book: %@", isbn);
	
	NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
        NSUInteger count = [myCachedEucBookCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out EucBook");
        } else {
            [myCachedEucBookCheckoutCounts removeObject:isbn];
            if (count == 1) {
                [myCachedEucBooks removeObjectForKey:isbn];
                if(myCachedEucBookCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedEucBookCheckoutCounts = nil;
                }
            }
        }
		
    }
	
}

#pragma mark -
#pragma mark TextFlow Check out/Check in

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(NSString *)isbn
{
    SCHTextFlow *ret = nil;
    
    // Always check out an XPS Provider alongside a TextFlow to guarantee that we have the 
    // same one underneath it for the duration of any decrypt operation
    [self checkOutXPSProviderForBookIdentifier:isbn];
    
    [self.persistentStoreCoordinator lock];
    
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        SCHTextFlow *previouslyCachedTextFlow = [myCachedTextFlows objectForKey:isbn];
        if(previouslyCachedTextFlow) {
            //NSLog(@"Returning cached TextFlow for book with ISBN %@", isbn);
            [self.cachedTextFlowCheckoutCounts addObject:isbn];
            ret = previouslyCachedTextFlow;
        } else {
            
            SCHTextFlow *textFlow = [[SCHTextFlow alloc] initWithISBN:isbn];
            
            if(textFlow) {
                //NSLog(@"Creating and caching TextFlow for book with ISBN %@", isbn);
                NSCountedSet *myCachedTextFlowCheckoutCounts = self.cachedTextFlowCheckoutCounts;
                if(!myCachedTextFlowCheckoutCounts) {
                    myCachedTextFlowCheckoutCounts = [NSCountedSet set];
                    self.cachedTextFlowCheckoutCounts = myCachedTextFlowCheckoutCounts;
                }
                [myCachedTextFlows setObject:textFlow forKey:isbn];
                [myCachedTextFlowCheckoutCounts addObject:isbn];
                [textFlow release];
                ret = textFlow;
            }
        }
    }
    
    [self.persistentStoreCoordinator unlock];
    
    return(ret);
}

- (void)checkInTextFlowForBookIdentifier:(NSString *)isbn
{
    // Always check in an XPS Provider alongside a TextFlow to match the fact 
    // that we always check it out
    [self checkInXPSProviderForBookIdentifier:isbn];
    
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        NSCountedSet *myCachedTextFlowCheckoutCounts = self.cachedTextFlowCheckoutCounts;
        NSUInteger count = [myCachedTextFlowCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out TextFlow");
        } else {
            [myCachedTextFlowCheckoutCounts removeObject:isbn];
            if (count == 1) {
                //NSLog(@"Releasing cached TextFlow for book with ISBN %@", isbn);
                [myCachedTextFlows removeObjectForKey:isbn];
                if(myCachedTextFlowCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedTextFlowCheckoutCounts = nil;
                }
            }
        }
    }
}

#pragma mark -
#pragma mark ParagraphSource Check out/Check in

- (SCHTextFlowParagraphSource *)checkOutParagraphSourceForBookIdentifier:(NSString *)isbn
{   
    SCHTextFlowParagraphSource *ret = nil;
    
    [self.persistentStoreCoordinator lock];
    
    NSMutableDictionary *myCachedParagraphSources = self.cachedParagraphSources;
    @synchronized(myCachedParagraphSources) {
        SCHTextFlowParagraphSource *previouslyCachedParagraphSource = [myCachedParagraphSources objectForKey:isbn];
        if(previouslyCachedParagraphSource) {
            //NSLog(@"Returning cached ParagraphSource for book with ID %@", aBookID);
            [self.cachedParagraphSourceCheckoutCounts addObject:isbn];
            ret= previouslyCachedParagraphSource;
        } else {
            SCHTextFlowParagraphSource *paragraphSource = [[SCHTextFlowParagraphSource alloc] initWithISBN:isbn];
            
            if(paragraphSource) {
                //NSLog(@"Creating and caching ParagraphSource for book with ID %@", aBookID);
                NSCountedSet *myCachedParagraphSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
                if(!myCachedParagraphSourceCheckoutCounts) {
                    myCachedParagraphSourceCheckoutCounts = [NSCountedSet set];
                    self.cachedParagraphSourceCheckoutCounts = myCachedParagraphSourceCheckoutCounts;
                }
                [myCachedParagraphSources setObject:paragraphSource forKey:isbn];
                [myCachedParagraphSourceCheckoutCounts addObject:isbn];
                [paragraphSource release];
                ret = paragraphSource;
            }
        }
    }
    
    [self.persistentStoreCoordinator unlock];
    
    return(ret);
}

- (void)checkInParagraphSourceForBookIdentifier:(NSString *)isbn
{
    NSMutableDictionary *myCachedParagraphSources = self.cachedParagraphSources;
    @synchronized(myCachedParagraphSources) {
        NSCountedSet *myCachedParagraphSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
        NSUInteger count = [myCachedParagraphSourceCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out paragraph source");
        } else {
            [myCachedParagraphSourceCheckoutCounts removeObject:isbn];
            if (count == 1) {
                //NSLog(@"Releasing cached paragraph source for book with ID %@", aBookID);
                [myCachedParagraphSources removeObjectForKey:isbn];
                if(myCachedParagraphSourceCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedParagraphSourceCheckoutCounts = nil;
                }
            }
        }
    }
}

#pragma mark - ParagraphSource Check out/Check in

- (SCHSmartZoomBlockSource *)checkOutBlockSourceForBookIdentifier:(NSString *)isbn
{   
    SCHSmartZoomBlockSource *ret = nil;
    
    [self.persistentStoreCoordinator lock];
    
    NSMutableDictionary *myCachedBlockSources = self.cachedBlockSources;
    @synchronized(myCachedBlockSources) {
        SCHSmartZoomBlockSource *previouslyCachedBlockSource = [myCachedBlockSources objectForKey:isbn];
        if(previouslyCachedBlockSource) {
            [self.cachedBlockSourceCheckoutCounts addObject:isbn];
            ret= previouslyCachedBlockSource;
        } else {
            SCHSmartZoomBlockSource *blockSource = [[SCHSmartZoomBlockSource alloc] initWithISBN:isbn];
            
            if(blockSource) {
                NSCountedSet *myCachedBlockSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
                if(!myCachedBlockSourceCheckoutCounts) {
                    myCachedBlockSourceCheckoutCounts = [NSCountedSet set];
                    self.cachedBlockSourceCheckoutCounts = myCachedBlockSourceCheckoutCounts;
                }
                [myCachedBlockSources setObject:blockSource forKey:isbn];
                [myCachedBlockSourceCheckoutCounts addObject:isbn];
                [blockSource release];
                ret = blockSource;
            }
        }
    }
    
    [self.persistentStoreCoordinator unlock];
    
    return(ret);
}

- (void)checkInBlockSourceForBookIdentifier:(NSString *)isbn
{
    NSMutableDictionary *myCachedBlockSources = self.cachedParagraphSources;
    @synchronized(myCachedBlockSources) {
        NSCountedSet *myCachedBlockSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
        NSUInteger count = [myCachedBlockSourceCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out paragraph source");
        } else {
            [myCachedBlockSourceCheckoutCounts removeObject:isbn];
            if (count == 1) {
                [myCachedBlockSources removeObjectForKey:isbn];
                if(myCachedBlockSourceCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedBlockSourceCheckoutCounts = nil;
                }
            }
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - Checkouts: textFlows:<%d> xpsProviders<%d> eucBooks<%d> paragraphSources<%d> blockSources<%d>",
            [self class],
            self,
            [cachedTextFlowCheckoutCounts count],
            [cachedXPSProviderCheckoutCounts count],
            [cachedEucBookCheckoutCounts count],
            [cachedParagraphSourceCheckoutCounts count],
            [cachedBlockSourceCheckoutCounts count]];
}

@end
