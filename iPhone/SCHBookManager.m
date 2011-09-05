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
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	        
    }
    return(self);
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[threadSafeMutationLock release], threadSafeMutationLock = nil;
	[cachedXPSProviders release], cachedXPSProviders = nil;
    [cachedEucBooks release], cachedEucBooks = nil;
    [cachedTextFlows release], cachedTextFlows = nil;
    [cachedParagraphSources release], cachedParagraphSources = nil;
    [isbnManagedObjectCache release], isbnManagedObjectCache = nil;
    [mainThreadManagedObjectContext release], mainThreadManagedObjectContext = nil;
    [super dealloc];
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.mainThreadManagedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
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

- (SCHAppBook *)bookWithIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSAssert(identifier != nil, @"nil identifier at bookWithIdentifier");
    NSAssert(managedObjectContext != nil, @"nil managedObjectContext at bookWithIdentifier");
    
    SCHAppBook *book = nil;
    NSError *error = nil;
    NSManagedObjectID *managedObjectID = nil;
    
    @synchronized(self.isbnManagedObjectCache) {
        managedObjectID = [self.isbnManagedObjectCache objectForKey:identifier];
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
                                    substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           identifier.isbn, kSCHAppBookCONTENT_IDENTIFIER,
                                                           identifier.DRMQualifier, kSCHAppBookDRM_QUALIFIER,
                                                           nil]];
    [fetchRequest setFetchLimit:1];
    NSArray *bookArray = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!bookArray) {
        NSLog(@"Error while fetching book item: %@", [error localizedDescription]);
    } else if ([bookArray count] > 0) {
        book = (SCHAppBook *)[bookArray objectAtIndex:0];
        if (![book.objectID isTemporaryID]) {
            @synchronized(self.isbnManagedObjectCache) {
                [self.isbnManagedObjectCache setObject:book.objectID forKey:identifier];
            }
        }
    }
    
    return book;
}

- (void)removeBookIdentifierFromCache:(SCHBookIdentifier *)identifier
{
    @synchronized(self.isbnManagedObjectCache) {
        [self.isbnManagedObjectCache removeObjectForKey:identifier];
    }
}

- (void)clearBookIdentifierCache
{
    @synchronized(self.isbnManagedObjectCache) {
        [self.isbnManagedObjectCache removeAllObjects];
    }
}

- (NSArray *)allBookIdentifiersInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
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
                SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:contentMetadataItem.ContentIdentifier
                                                                           DRMQualifier:contentMetadataItem.DRMQualifier];
                [ret addObject:identifier];
                [identifier release];
            }
        }
    }
    
    return(ret);
}

- (void)performOnMainThread:(dispatch_block_t)block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark - XPS Provider Check out/Check in

static int checkoutCountXPS = 0;
static int allocCountXPS = 0;

- (SCHXPSProvider *)checkOutXPSProviderForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	SCHXPSProvider *ret = nil;
	
    checkoutCountXPS++;
    
	//NSLog(@"Checking out XPS for book: %@, count is %d", identifier, checkoutCountXPS);
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        SCHXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:identifier];
        if(previouslyCachedXPSProvider) {
            //NSLog(@"Returning cached XPSProvider for book with identifier %@", identifier);
            [self.cachedXPSProviderCheckoutCounts addObject:identifier];
            ret = previouslyCachedXPSProvider;
        } else {
            allocCountXPS++;
            SCHAppBook *book = [self bookWithIdentifier:identifier inManagedObjectContext:managedObjectContext];
			SCHXPSProvider *xpsProvider = [[SCHXPSProvider alloc] initWithBookIdentifier:identifier xpsPath:[book xpsPath]];
			if(xpsProvider) {
				NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
				if(!myCachedXPSProviderCheckoutCounts) {
					myCachedXPSProviderCheckoutCounts = [NSCountedSet set];
					self.cachedXPSProviderCheckoutCounts = myCachedXPSProviderCheckoutCounts;
				}
				
				[myCachedXPSProviders setObject:xpsProvider forKey:identifier];
				[myCachedXPSProviderCheckoutCounts addObject:identifier];
				ret = xpsProvider;
				[xpsProvider release];
			}
        }
    }
    
    //NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:identifier], identifier);

    return(ret);	
}

- (SCHXPSProvider *)threadSafeCheckOutXPSProviderForBookIdentifier:(SCHBookIdentifier *)identifier
{
    __block SCHXPSProvider *xpsProvider = nil;
    [self performOnMainThread:^{
        xpsProvider = [[self checkOutXPSProviderForBookIdentifier:identifier inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    }];
    return [xpsProvider autorelease];
}

- (void)checkInXPSProviderForBookIdentifier:(SCHBookIdentifier *)identifier
{

    //NSLog(@"Checking in XPS for book: %@", identifier);
	
	NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
        NSUInteger count = [myCachedXPSProviderCheckoutCounts countForObject:identifier];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out XPSProvider");
        } else {
            [myCachedXPSProviderCheckoutCounts removeObject:identifier];
            if (count == 1) {
                //NSLog(@"Releasing cached XPSProvider for book with identifier %@", identifier);
                [myCachedXPSProviders removeObjectForKey:identifier];
                if(myCachedXPSProviderCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedXPSProviderCheckoutCounts = nil;
                }
            }
        }
        //NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:identifier], identifier);
		
    }
	
}

#pragma mark - EucBook Check out/Check in

static int checkoutCountEucBook = 0;

- (SCHFlowEucBook *)checkOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	SCHFlowEucBook *ret = nil;
	
    checkoutCountEucBook++;
    
   // NSLog(@"Checking out EucBook for book: %@, count is %d", identifier, checkoutCountEucBook);

	//NSLog(@"Checking out EucBook for book: %@", identifier);
	
    NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        SCHFlowEucBook *previouslyCachedEucBook = [myCachedEucBooks objectForKey:identifier];
        if(previouslyCachedEucBook) {
            //NSLog(@"Returning cached EucBook for book with identifier %@", identifier);
            [self.cachedEucBookCheckoutCounts addObject:identifier];
            ret = previouslyCachedEucBook;
        } else {
			SCHFlowEucBook *eucBook = [[SCHFlowEucBook alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
			if(eucBook) {
				NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
				if(!myCachedEucBookCheckoutCounts) {
					myCachedEucBookCheckoutCounts = [NSCountedSet set];
					self.cachedEucBookCheckoutCounts = myCachedEucBookCheckoutCounts;
				}
				
				[myCachedEucBooks setObject:eucBook forKey:identifier];
				[myCachedEucBookCheckoutCounts addObject:identifier];
                [eucBook autorelease];
				ret = eucBook;
			}
        }
    }
    
    return(ret);
}

- (SCHFlowEucBook *)threadSafeCheckOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier
{
    __block SCHFlowEucBook *eucBook;
    [self performOnMainThread:^{
        eucBook = [[self checkOutEucBookForBookIdentifier:identifier inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    }];
    return [eucBook autorelease];
}

- (void)checkInEucBookForBookIdentifier:(SCHBookIdentifier *)identifier
{
    
	//NSLog(@"Checking in EucBook for book: %@", identifier);
	
	NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
        NSUInteger count = [myCachedEucBookCheckoutCounts countForObject:identifier];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out EucBook");
        } else {
            [myCachedEucBookCheckoutCounts removeObject:identifier];
            if (count == 1) {
                [myCachedEucBooks removeObjectForKey:identifier];
                if(myCachedEucBookCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedEucBookCheckoutCounts = nil;
                }
            }
        }
		
    }
	
}

#pragma mark - TextFlow Check out/Check in

static int checkoutCountTextFlow = 0;

- (SCHTextFlow *)checkOutTextFlowForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
    SCHTextFlow *ret = nil;
        
    checkoutCountTextFlow++;
    
   // NSLog(@"Checking out TextFlow for book: %@, count is %d", isbn, checkoutCountTextFlow);
    
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        SCHTextFlow *previouslyCachedTextFlow = [myCachedTextFlows objectForKey:identifier];
        if(previouslyCachedTextFlow) {
            //NSLog(@"Returning cached TextFlow for book with identifier %@", identifier);
            [self.cachedTextFlowCheckoutCounts addObject:identifier];
            ret = previouslyCachedTextFlow;
        } else {
            
            SCHTextFlow *textFlow = [[SCHTextFlow alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            
            if(textFlow) {
                //NSLog(@"Creating and caching TextFlow for book with identifier %@", identifier);
                NSCountedSet *myCachedTextFlowCheckoutCounts = self.cachedTextFlowCheckoutCounts;
                if(!myCachedTextFlowCheckoutCounts) {
                    myCachedTextFlowCheckoutCounts = [NSCountedSet set];
                    self.cachedTextFlowCheckoutCounts = myCachedTextFlowCheckoutCounts;
                }
                [myCachedTextFlows setObject:textFlow forKey:identifier];
                [myCachedTextFlowCheckoutCounts addObject:identifier];
                [textFlow release];
                ret = textFlow;
            }
        }
    }
    
    return(ret);
}

- (void)checkInTextFlowForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        NSCountedSet *myCachedTextFlowCheckoutCounts = self.cachedTextFlowCheckoutCounts;
        NSUInteger count = [myCachedTextFlowCheckoutCounts countForObject:identifier];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out TextFlow");
        } else {
            [myCachedTextFlowCheckoutCounts removeObject:identifier];
            if (count == 1) {
                //NSLog(@"Releasing cached TextFlow for book with identifier %@", identifier);
                [myCachedTextFlows removeObjectForKey:identifier];
                if(myCachedTextFlowCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedTextFlowCheckoutCounts = nil;
                }
            }
        }
    }
}

#pragma mark - ParagraphSource Check out/Check in

static int checkoutCountParagraph = 0;

- (SCHTextFlowParagraphSource *)checkOutParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{   
    checkoutCountParagraph++;
    //NSLog(@"Checking out ParagraphSource for book: %@, count is %d", identifier, checkoutCountParagraph);
    SCHTextFlowParagraphSource *ret = nil;
    
    NSMutableDictionary *myCachedParagraphSources = self.cachedParagraphSources;
    @synchronized(myCachedParagraphSources) {
        SCHTextFlowParagraphSource *previouslyCachedParagraphSource = [myCachedParagraphSources objectForKey:identifier];
        if(previouslyCachedParagraphSource) {
            //NSLog(@"Returning cached ParagraphSource for book with ID %@", identifier);
            [self.cachedParagraphSourceCheckoutCounts addObject:identifier];
            ret= previouslyCachedParagraphSource;
        } else {
            SCHTextFlowParagraphSource *paragraphSource = [[SCHTextFlowParagraphSource alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            
            if(paragraphSource) {
                //NSLog(@"Creating and caching ParagraphSource for book with ID %@", identifier);
                NSCountedSet *myCachedParagraphSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
                if(!myCachedParagraphSourceCheckoutCounts) {
                    myCachedParagraphSourceCheckoutCounts = [NSCountedSet set];
                    self.cachedParagraphSourceCheckoutCounts = myCachedParagraphSourceCheckoutCounts;
                }
                [myCachedParagraphSources setObject:paragraphSource forKey:identifier];
                [myCachedParagraphSourceCheckoutCounts addObject:identifier];
                [paragraphSource release];
                ret = paragraphSource;
            }
        }
    }
    
    return(ret);
}

- (void)checkInParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSMutableDictionary *myCachedParagraphSources = self.cachedParagraphSources;
    @synchronized(myCachedParagraphSources) {
        NSCountedSet *myCachedParagraphSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
        NSUInteger count = [myCachedParagraphSourceCheckoutCounts countForObject:identifier];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out paragraph source");
        } else {
            [myCachedParagraphSourceCheckoutCounts removeObject:identifier];
            if (count == 1) {
                //NSLog(@"Releasing cached paragraph source for book with ID %@", identifier);
                [myCachedParagraphSources removeObjectForKey:identifier];
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
