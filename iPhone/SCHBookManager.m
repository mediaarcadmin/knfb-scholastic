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
#import "SCHEPubBook.h"
#import "SCHTextFlowParagraphSource.h"
#import "SCHEPubToTextFlowMappingParagraphSource.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "KNFBParagraphSource.h"
#import <libEucalyptus/EucEPubBook.h>

static const NSUInteger kSCHBookManagerAppBookCacheCountLimit = 100;

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

@property (nonatomic, retain) NSCache *appBookCache;

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
@synthesize appBookCache;
@synthesize mainThreadManagedObjectContext;

+ (SCHBookManager *)sharedBookManager
{
    // We don't need to bother being thread-safe in the initialisation here,
    // because the object can't be used until the NSPersistentStoreCoordinator 
    // is set, so that has to be all done on the main thread before other calls
    // are made anyway.
    if(!sSharedBookManager) {
        sSharedBookManager = [[self alloc] init];
		sSharedBookManager.threadSafeMutationLock = [[[NSLock alloc] init] autorelease];

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
        appBookCache = [[NSCache alloc] init];
        [appBookCache setCountLimit:kSCHBookManagerAppBookCacheCountLimit];

        
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
    [appBookCache release], appBookCache = nil;
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
        
    if (identifier == nil) {
        return nil;
    }
    
    SCHAppBook *appBook = [self.appBookCache objectForKey:identifier];
    
    
    if (appBook) {
        return appBook;
    }
    
    NSError *error = nil;
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
        appBook = (SCHAppBook *)[bookArray objectAtIndex:0];
        if (![appBook.objectID isTemporaryID]) {
            [self.appBookCache setObject:appBook forKey:identifier];
        }
    }
    
    return appBook;
}

- (void)removeBookIdentifierFromCache:(SCHBookIdentifier *)identifier
{
    if (identifier != nil) {
        [self.appBookCache removeObjectForKey:identifier];
    }
}

- (void)clearBookIdentifierCache
{
    [self.appBookCache removeAllObjects];
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
    if (allBooks == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
	
    if ([allBooks count] > 0) {
        ret = [NSMutableArray arrayWithCapacity:[allBooks count]];
        for (SCHContentMetadataItem *contentMetadataItem in allBooks) {
            
            // defensive : only add the book if it actually has an ISBN & DRM Qualifier
            if (contentMetadataItem.ContentIdentifier && contentMetadataItem.DRMQualifier) {
                SCHBookIdentifier *bookIdentifier = [contentMetadataItem bookIdentifier];
                if (bookIdentifier != nil) {
                    [ret addObject:bookIdentifier];
                }
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
    NSParameterAssert(identifier);
    
	SCHXPSProvider *ret = nil;
	
    checkoutCountXPS++;
    
	//NSLog(@"Checking out XPS for book: %@, count is %d", identifier, checkoutCountXPS);
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        SCHXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:identifier];
        if(previouslyCachedXPSProvider) {
            //NSLog(@"Returning cached XPSProvider for book with identifier %@", identifier);
            if (identifier != nil) {
                [self.cachedXPSProviderCheckoutCounts addObject:identifier];
            }
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
                if (identifier != nil) {
                    [myCachedXPSProviderCheckoutCounts addObject:identifier];
                }
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
    NSParameterAssert(identifier);
    
    __block SCHXPSProvider *xpsProvider = nil;
    [self performOnMainThread:^{
        xpsProvider = [[self checkOutXPSProviderForBookIdentifier:identifier inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    }];
    return [xpsProvider autorelease];
}

- (void)checkInXPSProviderForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
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
                if (identifier != nil) {
                    [myCachedXPSProviders removeObjectForKey:identifier];
                }
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

- (EucEPubBook<SCHEPubBookmarkPointTranslation> *)checkOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert(identifier);
    
	EucEPubBook<SCHEPubBookmarkPointTranslation> *ret = nil;
	
    checkoutCountEucBook++;
    
   // NSLog(@"Checking out EucBook for book: %@, count is %d", identifier, checkoutCountEucBook);

	//NSLog(@"Checking out EucBook for book: %@", identifier);
	
    NSMutableDictionary *myCachedEucBooks = self.cachedEucBooks;
    @synchronized(myCachedEucBooks) {
        SCHFlowEucBook *previouslyCachedEucBook = [myCachedEucBooks objectForKey:identifier];
        if(previouslyCachedEucBook) {
            //NSLog(@"Returning cached EucBook for book with identifier %@", identifier);
            if (identifier != nil) {
                [self.cachedEucBookCheckoutCounts addObject:identifier];
            }
            ret = previouslyCachedEucBook;
        } else {
            EucEPubBook<SCHEPubBookmarkPointTranslation> *eucBook = nil;
            
            SCHXPSProvider *xpsProvider = [self checkOutXPSProviderForBookIdentifier:identifier inManagedObjectContext:managedObjectContext];
            BOOL hasEPub = [xpsProvider containsEmbeddedEPub];
            
            if (hasEPub) {
                eucBook = [[SCHEPubBook alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            } else {
                eucBook = [[SCHFlowEucBook alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            }
            
            [self checkInXPSProviderForBookIdentifier:identifier];
            
			if(eucBook) {
				NSCountedSet *myCachedEucBookCheckoutCounts = self.cachedEucBookCheckoutCounts;
				if(!myCachedEucBookCheckoutCounts) {
					myCachedEucBookCheckoutCounts = [NSCountedSet set];
					self.cachedEucBookCheckoutCounts = myCachedEucBookCheckoutCounts;
				}
				
				[myCachedEucBooks setObject:eucBook forKey:identifier];
                if (identifier != nil) {
                    [myCachedEucBookCheckoutCounts addObject:identifier];
                }
                [eucBook autorelease];
				ret = eucBook;
			}
        }
    }
    
    return(ret);
}

- (EucEPubBook<SCHEPubBookmarkPointTranslation> *)threadSafeCheckOutEucBookForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
    __block EucEPubBook<SCHEPubBookmarkPointTranslation> *eucBook;
    [self performOnMainThread:^{
        eucBook = [[self checkOutEucBookForBookIdentifier:identifier inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    }];
    return [eucBook autorelease];
}

- (void)checkInEucBookForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
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
                if (identifier != nil) {
                    [myCachedEucBooks removeObjectForKey:identifier];
                }
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
    NSParameterAssert(identifier);
    
    SCHTextFlow *ret = nil;
        
    checkoutCountTextFlow++;
    
   // NSLog(@"Checking out TextFlow for book: %@, count is %d", isbn, checkoutCountTextFlow);
    
    NSMutableDictionary *myCachedTextFlows = self.cachedTextFlows;
    @synchronized(myCachedTextFlows) {
        SCHTextFlow *previouslyCachedTextFlow = [myCachedTextFlows objectForKey:identifier];
        if(previouslyCachedTextFlow) {
            //NSLog(@"Returning cached TextFlow for book with identifier %@", identifier);
            if (identifier != nil) {
                [self.cachedTextFlowCheckoutCounts addObject:identifier];
            }
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
                if (identifier != nil) {
                    [myCachedTextFlowCheckoutCounts addObject:identifier];
                }
                [textFlow release];
                ret = textFlow;
            }
        }
    }
    
    return(ret);
}

- (void)checkInTextFlowForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
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
                if (identifier != nil) {
                    [myCachedTextFlows removeObjectForKey:identifier];
                }
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

- (id<KNFBParagraphSource>)threadSafeCheckOutParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
    __block id<KNFBParagraphSource> paragraphSource = nil;
    [self performOnMainThread:^{
        paragraphSource = [[self checkOutParagraphSourceForBookIdentifier:identifier inManagedObjectContext:self.mainThreadManagedObjectContext] retain];
    }];
    return [paragraphSource autorelease];
}

- (id<KNFBParagraphSource>)checkOutParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{   
    NSParameterAssert(identifier);
    
    checkoutCountParagraph++;
    //NSLog(@"Checking out ParagraphSource for book: %@, count is %d", identifier, checkoutCountParagraph);
    id<KNFBParagraphSource> ret = nil;
    
    NSMutableDictionary *myCachedParagraphSources = self.cachedParagraphSources;
    @synchronized(myCachedParagraphSources) {
        id<KNFBParagraphSource> previouslyCachedParagraphSource = [myCachedParagraphSources objectForKey:identifier];
        if(previouslyCachedParagraphSource) {
            //NSLog(@"Returning cached ParagraphSource for book with ID %@", identifier);
            if (identifier != nil) {
                [self.cachedParagraphSourceCheckoutCounts addObject:identifier];
            }
            ret= previouslyCachedParagraphSource;
        } else {
            
            id<KNFBParagraphSource> paragraphSource = nil;
            
            SCHXPSProvider *xpsProvider = [self checkOutXPSProviderForBookIdentifier:identifier inManagedObjectContext:managedObjectContext];
            BOOL hasEPub = [xpsProvider containsEmbeddedEPub];
            
            if (hasEPub) {
                paragraphSource = [[SCHEPubToTextFlowMappingParagraphSource alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            } else {
                paragraphSource = [[SCHTextFlowParagraphSource alloc] initWithBookIdentifier:identifier managedObjectContext:managedObjectContext];
            }
            
            [self checkInXPSProviderForBookIdentifier:identifier];
                        
            if(paragraphSource) {
                //NSLog(@"Creating and caching ParagraphSource for book with ID %@", identifier);
                NSCountedSet *myCachedParagraphSourceCheckoutCounts = self.cachedParagraphSourceCheckoutCounts;
                if(!myCachedParagraphSourceCheckoutCounts) {
                    myCachedParagraphSourceCheckoutCounts = [NSCountedSet set];
                    self.cachedParagraphSourceCheckoutCounts = myCachedParagraphSourceCheckoutCounts;
                }
                [myCachedParagraphSources setObject:paragraphSource forKey:identifier];
                if (identifier != nil) {
                    [myCachedParagraphSourceCheckoutCounts addObject:identifier];
                }
                [paragraphSource release];
                ret = paragraphSource;
            }
        }
    }
    
    return(ret);
}

- (void)checkInParagraphSourceForBookIdentifier:(SCHBookIdentifier *)identifier
{
    NSParameterAssert(identifier);
    
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
                if (identifier != nil) {
                    [myCachedParagraphSources removeObjectForKey:identifier];
                }
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
