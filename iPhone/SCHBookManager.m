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

@interface SCHBookManager ()

@property (nonatomic, retain) NSMutableDictionary *cachedXPSProviders;
@property (nonatomic, retain) NSMutableDictionary *cachedEucBooks;
@property (nonatomic, retain) NSMutableDictionary *cachedTextFlows;
@property (nonatomic, retain) NSMutableDictionary *cachedParagraphSources;
@property (nonatomic, retain) NSCountedSet *cachedXPSProviderCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedEucBookCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedTextFlowCheckoutCounts;
@property (nonatomic, retain) NSCountedSet *cachedParagraphSourceCheckoutCounts;
@property (nonatomic, retain) NSLock *threadSafeMutationLock;

@property (nonatomic, retain) NSMutableDictionary *isbnManagedObjectCache;

@end


@implementation SCHBookManager

// the shared book manager object
static SCHBookManager *sSharedBookManager = nil;

// information from the feature compatibility plist
static NSDictionary *featureCompatibilityDictionary = nil;


@synthesize cachedXPSProviders;
@synthesize cachedXPSProviderCheckoutCounts;
@synthesize cachedEucBooks;
@synthesize cachedEucBookCheckoutCounts;
@synthesize cachedTextFlows;
@synthesize cachedParagraphSources;
@synthesize cachedTextFlowCheckoutCounts;
@synthesize cachedParagraphSourceCheckoutCounts;
@synthesize persistentStoreCoordinator;
@synthesize threadSafeMutationLock;
@synthesize isbnManagedObjectCache;
@synthesize mainThreadManagedObjectContext;

+ (SCHBookManager *)sharedBookManager
{
    // We don't need to bother being thread-safe in the initialisation here,
    // because the object can't be used until the NSPersistentStoreCoordinator 
    // is set, so that has to be all done on the main thread before other calls
    // are made anyway.
    if(!sSharedBookManager) {
        sSharedBookManager = [[self alloc] init];
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
    [isbnManagedObjectCache release], isbnManagedObjectCache = nil;
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    [super dealloc];
}

#pragma mark - Compatibility Checking

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

#pragma mark - Book Info vending

- (SCHAppBook *)bookWithIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSAssert(isbn != nil, @"nil ISBN at bookWithIdentifier");
    NSAssert(managedObjectContext != nil, @"nil managedObjectContext at bookWithIdentifier");
    
    SCHAppBook *book = nil;
    NSError *error = nil;
    NSManagedObjectID *managedObjectID = nil;
    
    @synchronized(self.isbnManagedObjectCache) {
        managedObjectID = [self.isbnManagedObjectCache objectForKey:isbn];
    }
    if (managedObjectID != nil) {
        book = (SCHAppBook *) [managedObjectContext existingObjectWithID:managedObjectID error:&error];
        if (book == nil) {
            NSLog(@"failed to fetch book with existing ID %@: %@", managedObjectID, error);
        }
        return book;
    }
    
    NSFetchRequest *fetchRequest = [self.persistentStoreCoordinator.managedObjectModel 
                                    fetchRequestFromTemplateWithName:kSCHAppBookFetchWithContentIdentifier 
                                    substitutionVariables:[NSDictionary 
                                                           dictionaryWithObject:isbn 
                                                           forKey:kSCHAppBookCONTENT_IDENTIFIER]];
    [fetchRequest setFetchLimit:1];
    NSArray *bookArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!bookArray) {
        NSLog(@"Error while fetching book item: %@", [error localizedDescription]);
    } else if ([bookArray count] > 0) {
        book = (SCHAppBook *)[bookArray objectAtIndex:0];
        if (![book.objectID isTemporaryID]) {
            @synchronized(self.isbnManagedObjectCache) {
                [self.isbnManagedObjectCache setObject:book.objectID forKey:isbn];
            }
        }
    }
    
    return book;
}

- (NSArray *)allBooksAsISBNsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSMutableArray *ret = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHContentMetadataItem inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
	
	NSError *error = nil;				
	NSArray *allBooks = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
    if ([allBooks count] > 0) {
        ret = [NSMutableArray arrayWithCapacity:[allBooks count]];
        for (SCHContentMetadataItem *contentMetadataItem in allBooks) {
            
            // defensive : only add the book if it actually has an ISBN
            if (contentMetadataItem.ContentIdentifier) {
                [ret addObject:contentMetadataItem.ContentIdentifier];
            }
        }
    }
    
    return(ret);
}


#pragma mark - XPS Provider Check out/Check in

static int checkoutCountXPS = 0;
static int allocCountXPS = 0;

- (SCHXPSProvider *)checkOutXPSProviderForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	SCHXPSProvider *ret = nil;
	
    checkoutCountXPS++;
    
	//NSLog(@"Checking out XPS for book: %@, count is %d", isbn, checkoutCountXPS);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        SCHXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:isbn];
        if(previouslyCachedXPSProvider) {
            //NSLog(@"Returning cached XPSProvider for book with ISBN %@", isbn);
            [self.cachedXPSProviderCheckoutCounts addObject:isbn];
            ret = previouslyCachedXPSProvider;
        } else {
            allocCountXPS++;
            SCHAppBook *book = [self bookWithIdentifier:isbn inManagedObjectContext:managedObjectContext];
			SCHXPSProvider *xpsProvider = [[SCHXPSProvider alloc] initWithISBN:isbn xpsPath:[book xpsPath]];
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

- (SCHXPSProvider *)threadSafeCheckOutXPSProviderForBookIdentifier:(NSString *)isbn
{
    __block SCHXPSProvider *xpsProvider = nil;
    dispatch_block_t getBlock = ^{
        xpsProvider = [[self checkOutXPSProviderForBookIdentifier:isbn inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    };
    if (dispatch_get_current_queue() == dispatch_get_main_queue()) {
        getBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), getBlock);
    }
    return [xpsProvider autorelease];
}

- (void)checkInXPSProviderForBookIdentifier:(NSString *)isbn
{

    //NSLog(@"Checking in XPS for book: %@", isbn);
	
	NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
        NSUInteger count = [myCachedXPSProviderCheckoutCounts countForObject:isbn];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out XPSProvider");
        } else {
            [myCachedXPSProviderCheckoutCounts removeObject:isbn];
            if (count == 1) {
                //NSLog(@"Releasing cached XPSProvider for book with isbn %@", isbn);
                [myCachedXPSProviders removeObjectForKey:isbn];
                if(myCachedXPSProviderCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedXPSProviderCheckoutCounts = nil;
                }
            }
        }
        //NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:isbn], isbn);
		
    }
	
}

#pragma mark -
#pragma mark EucBook Check out/Check in
static int checkoutCountEucBook = 0;
- (SCHFlowEucBook *)checkOutEucBookForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	SCHFlowEucBook *ret = nil;
	
    checkoutCountEucBook++;
    
   // NSLog(@"Checking out EucBook for book: %@, count is %d", isbn, checkoutCountEucBook);

	//NSLog(@"Checking out EucBook for book: %@", isbn);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        SCHFlowEucBook *previouslyCachedEucBook = [myCachedEucBooks objectForKey:isbn];
        if(previouslyCachedEucBook) {
            //NSLog(@"Returning cached EucBook for book with ISBN %@", isbn);
            [self.cachedEucBookCheckoutCounts addObject:isbn];
            ret = previouslyCachedEucBook;
        } else {
			SCHFlowEucBook *eucBook = [[SCHFlowEucBook alloc] initWithISBN:isbn managedObjectContext:managedObjectContext];
			if(eucBook) {
				NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
				if(!myCachedEucBookCheckoutCounts) {
					myCachedEucBookCheckoutCounts = [NSCountedSet set];
					self.cachedEucBookCheckoutCounts = myCachedEucBookCheckoutCounts;
				}
				
				[myCachedEucBooks setObject:eucBook forKey:isbn];
				[myCachedEucBookCheckoutCounts addObject:isbn];
                [eucBook autorelease];
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
static int checkoutCountTextFlow = 0;

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
    SCHTextFlow *ret = nil;
        
    checkoutCountTextFlow++;
    
   // NSLog(@"Checking out TextFlow for book: %@, count is %d", isbn, checkoutCountTextFlow);
    
    [self.persistentStoreCoordinator lock];
    
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        SCHTextFlow *previouslyCachedTextFlow = [myCachedTextFlows objectForKey:isbn];
        if(previouslyCachedTextFlow) {
            //NSLog(@"Returning cached TextFlow for book with ISBN %@", isbn);
            [self.cachedTextFlowCheckoutCounts addObject:isbn];
            ret = previouslyCachedTextFlow;
        } else {
            
            SCHTextFlow *textFlow = [[SCHTextFlow alloc] initWithISBN:isbn managedObjectContext:managedObjectContext];
            
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

static int checkoutCountParagraph = 0;

- (SCHTextFlowParagraphSource *)checkOutParagraphSourceForBookIdentifier:(NSString *)isbn inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{   
    checkoutCountParagraph++;
    //NSLog(@"Checking out ParagraphSource for book: %@, count is %d", isbn, checkoutCountParagraph);
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
            SCHTextFlowParagraphSource *paragraphSource = [[SCHTextFlowParagraphSource alloc] initWithISBN:isbn managedObjectContext:managedObjectContext];
            
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - Checkouts: textFlows: <%d> (%d) xpsProviders <%d> (%d) [%d] eucBooks <%d> (%d) paragraphSources <%d> (%d)",
            [self class],
            self,
            [cachedTextFlowCheckoutCounts count], checkoutCountTextFlow,
            [cachedXPSProviderCheckoutCounts count], checkoutCountXPS, allocCountXPS,
            [cachedEucBookCheckoutCounts count], checkoutCountEucBook,
            [cachedParagraphSourceCheckoutCounts count], checkoutCountParagraph];
}

@end
