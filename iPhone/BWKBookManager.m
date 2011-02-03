//
//  BWKBookManager.m
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "BWKBookManager.h"
#import "BWKXPSProvider.h"

@interface BWKBookManager ()

@property (nonatomic, retain) NSMutableDictionary *cachedXPSProviders;
@property (nonatomic, retain) NSCountedSet *cachedXPSProviderCheckoutCounts;
@property (nonatomic, retain) NSLock *checkInOutLock;

@end


@implementation BWKBookManager

static BWKBookManager *sSharedBookManager = nil;

@synthesize cachedXPSProviders, cachedXPSProviderCheckoutCounts, checkInOutLock;

+ (BWKBookManager *)sharedBookManager
{
    // We don't need to bother being thread-safe in the initialisation here,
    // because the object can't be used until the NSPersistentStoreCoordinator 
    // is set, so that has to be all done on the main thread before other calls
    // are made anyway.
    if(!sSharedBookManager) {
        sSharedBookManager = [[self alloc] init];
		// FIXME: deferred until decisions are made on locking strategy
        // By setting this, if we associate an object with sManagedObjectContextKey
        // using pthread_setspecific, CFRelease will be called on it before
        // the thread terminates.
        //pthread_key_create(&sManagedObjectContextKey, (void (*)(void *))CFRelease);
    }
    return sSharedBookManager;
}


- (id)init
{
    if (self = [super init]) {
        // Initialization code.
		self.checkInOutLock = [[NSLock alloc] init];
		self.cachedXPSProviders = [[NSMutableDictionary alloc] init];
    }
    return self;
}



- (BWKXPSProvider *)checkOutXPSProviderForBookWithPath:(NSString *)path
{
	BWKXPSProvider *ret = nil;
	
	NSLog(@"Checking out path: %@", path);
	
	//[self.checkInOutLock lock];
	
    NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        BWKXPSProvider *previouslyCachedXPSProvider = [myCachedXPSProviders objectForKey:path];
        if(previouslyCachedXPSProvider) {
            NSLog(@"Returning cached XPSProvider for book with path %@", path);
            [self.cachedXPSProviderCheckoutCounts addObject:path];
            ret = previouslyCachedXPSProvider;
        } else {
			BWKXPSProvider *xpsProvider = [[BWKXPSProvider alloc] initWithPath:path];
			if(xpsProvider) {
				NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
				if(!myCachedXPSProviderCheckoutCounts) {
					myCachedXPSProviderCheckoutCounts = [NSCountedSet set];
					self.cachedXPSProviderCheckoutCounts = myCachedXPSProviderCheckoutCounts;
				}
				
				[myCachedXPSProviders setObject:xpsProvider forKey:path];
				[myCachedXPSProviderCheckoutCounts addObject:path];
//				[xpsProvider release];
				ret = xpsProvider;
			}
        }
    }
    
	//[self.checkInOutLock unlock];
	
    //NSLog(@"[%d] checkOutXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:aBookID], aBookID);
    return ret;
	
}

- (void)checkInXPSProviderForBookWithPath:(NSString *)path
{

	NSLog(@"Checking in path: %@", path);
	
	NSMutableDictionary *myCachedXPSProviders = self.cachedXPSProviders;
    @synchronized(myCachedXPSProviders) {
        NSCountedSet *myCachedXPSProviderCheckoutCounts = self.cachedXPSProviderCheckoutCounts;
        NSUInteger count = [myCachedXPSProviderCheckoutCounts countForObject:path];
        if(count == 0) {
            NSLog(@"Warning! Unexpected checkin of non-checked-out XPSProvider");
        } else {
            [myCachedXPSProviderCheckoutCounts removeObject:path];
            if (count == 1) {
                //NSLog(@"Releasing cached XPSProvider for book with ID %@", aBookID);
                [myCachedXPSProviders removeObjectForKey:path];
                if(myCachedXPSProviderCheckoutCounts.count == 0) {
                    // May as well release the set.
                    self.cachedXPSProviderCheckoutCounts = nil;
                }
            }
        }
        //NSLog(@"[%d] checkInXPSProviderForBookWithID %@", [self.cachedXPSProviderCheckoutCounts countForObject:aBookID], aBookID);
		
    }
	
}

- (void)dealloc {
	[cachedXPSProviders release], cachedXPSProviders = nil;
	[checkInOutLock release], checkInOutLock = nil;
    [super dealloc];
}


@end
