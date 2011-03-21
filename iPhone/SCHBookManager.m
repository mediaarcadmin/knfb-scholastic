//
//  SCHBookManager.m
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookManager.h"
#import <pthread.h>
#import "SCHBookInfo.h"
#import "SCHBookContents.h"

@interface SCHBookManager ()

@property (nonatomic, retain) NSMutableDictionary *cachedXPSProviders;
@property (nonatomic, retain) NSCountedSet *cachedXPSProviderCheckoutCounts;

@end


@implementation SCHBookManager

// the shared book manager object
static SCHBookManager *sSharedBookManager = nil;

// used to keep track of manage contexts
static pthread_key_t sManagedObjectContextKey;

// used to hold unique book info objects
static NSMutableDictionary *bookTrackingDictionary = nil;
static NSDictionary *featureCompatibilityDictionary = nil;


@synthesize cachedXPSProviders, cachedXPSProviderCheckoutCounts, persistentStoreCoordinator;

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
		
		featureCompatibilityDictionary = 
		[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] 
													stringByAppendingPathComponent:@"ScholasticFeatureCompatibility.plist"]];

    }
    return sSharedBookManager;
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

+ (SCHBookInfo *) bookInfoWithBookIdentifier: (NSString *) isbn
{
	if (!bookTrackingDictionary) {
		bookTrackingDictionary = [[NSMutableDictionary alloc] init];
	}
	
	SCHBookInfo *existingBookInfo = [bookTrackingDictionary objectForKey:isbn];
	
	if (existingBookInfo) {
		//[bookTrackingDictionary setValue:existingBookInfo forKey:isbn];
		return existingBookInfo;
	} else {
		SCHBookInfo *bookInfo = [[SCHBookInfo alloc] init];
		bookInfo.bookIdentifier = isbn;
		[bookTrackingDictionary setValue:bookInfo forKey:isbn];
		return [bookInfo autorelease];
	}
}

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

- (BITXPSProvider *)checkOutXPSProviderForBook: (SCHBookInfo *) bookInfo
{
	BITXPSProvider *ret = nil;
	
	//NSLog(@"Checking out book ID: %@", bookID);
	
	[self.persistentStoreCoordinator lock];
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        BITXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:bookInfo.bookIdentifier];
        if(previouslyCachedXPSProvider) {
            NSLog(@"Returning cached XPSProvider for book with bookInfo %@", bookInfo);
            [self.cachedXPSProviderCheckoutCounts addObject:bookInfo];
            ret = previouslyCachedXPSProvider;
        } else {
			BITXPSProvider *xpsProvider = [[BITXPSProvider alloc] initWithBookInfo:bookInfo];
			if(xpsProvider) {
				NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
				if(!myCachedXPSProviderCheckoutCounts) {
					myCachedXPSProviderCheckoutCounts = [NSCountedSet set];
					self.cachedXPSProviderCheckoutCounts = myCachedXPSProviderCheckoutCounts;
				}
				
				[myCachedXPSProviders setObject:xpsProvider forKey:bookInfo.bookIdentifier];
				[myCachedXPSProviderCheckoutCounts addObject:bookInfo];
				ret = xpsProvider;
				[xpsProvider release];
			}
        }
    }
    
	[self.persistentStoreCoordinator unlock];
	
  //  NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookID], bookID);
    return ret;
	
}

- (void)checkInXPSProviderForBook: (SCHBookInfo *) bookInfo
{

	//NSLog(@"Checking in bookID: %@", bookInfo);
	
	NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
        NSUInteger count = [myCachedXPSProviderCheckoutCounts countForObject:bookInfo];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out XPSProvider");
        } else {
            [myCachedXPSProviderCheckoutCounts removeObject:bookInfo];
            if (count == 1) {
              //  NSLog(@"Releasing cached XPSProvider for book with ID %@", bookInfo);
                [myCachedXPSProviders removeObjectForKey:bookInfo.bookIdentifier];
                if(myCachedXPSProviderCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedXPSProviderCheckoutCounts = nil;
                }
            }
        }
       // NSLog(@"[%d] checkInXPSProviderForBookWithPath %@", [self.cachedXPSProviderCheckoutCounts countForObject:bookInfo], bookInfo);
		
    }
	
}

- (void)dealloc {
	[cachedXPSProviders release], cachedXPSProviders = nil;
    [super dealloc];
}


@end
