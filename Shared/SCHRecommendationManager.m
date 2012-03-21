//
//  SCHRecommendationManager.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationManager.h"
#import "SCHCoreDataHelper.h"
#import "SCHRecommendationOperation.h"

@interface SCHRecommendationManager()

- (void)createProcessingQueues;
- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification;
- (BOOL)isbnIsProcessing:(NSString *)isbn;
- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn;

@property (readwrite, retain) NSOperationQueue *processingQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
@property (readwrite, retain) NSMutableSet *currentlyProcessingIsbns;

@end

static SCHRecommendationManager *sharedManager = nil;

@implementation SCHRecommendationManager

@synthesize managedObjectContext;
@synthesize processingQueue;
@synthesize backgroundTask;
@synthesize currentlyProcessingIsbns;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                               object:nil];	    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];			
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];	
    
    
    [managedObjectContext release], managedObjectContext = nil;
    [processingQueue release], processingQueue = nil;
    [currentlyProcessingIsbns release], currentlyProcessingIsbns = nil;
    [super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		[self createProcessingQueues];
        
        currentlyProcessingIsbns = [NSMutableSet set];
		        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	        
	}
	
	return self;
}

- (void)createProcessingQueues
{
    self.processingQueue = [[[NSOperationQueue alloc] init] autorelease];
    [self.processingQueue setMaxConcurrentOperationCount:2];
}

- (void)cancelAllOperations
{
    
}

- (void)cancelAllOperationsForIsbn:(NSString *)isbn
{
    @synchronized(self) {
        for (SCHRecommendationOperation *op in [self.processingQueue operations]) {
            if ([op.isbn isEqual:isbn] == YES) {
                [op cancel];
                break;
            }
        }
               
        [self.currentlyProcessingIsbns removeObject:isbn];
    }
}

#pragma mark - Processing

- (BOOL)isbnIsProcessing:(NSString *)isbn
{
    @synchronized(self.currentlyProcessingIsbns) {
        return [self.currentlyProcessingIsbns containsObject:isbn];
    }
}

- (void)setProcessing:(BOOL)processing forIsbn:(NSString *)isbn
{
    @synchronized(self.currentlyProcessingIsbns) {
        if (processing) {
            if (![self.currentlyProcessingIsbns containsObject:isbn]) {
                [self.currentlyProcessingIsbns addObject:isbn];
            }
            
        } else {
            [self.currentlyProcessingIsbns removeObject:isbn];
        }
    }
}

#pragma mark - Notification handlers

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
}

- (void)enterBackground
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
    if(backgroundSupported) {        
		
        // if there's already a background monitoring task, then return - the existing one will work
        if (self.backgroundTask && self.backgroundTask != UIBackgroundTaskInvalid) {
            return;
        }
        
		if (([self.processingQueue operationCount] > 0)) {
			NSLog(@"Recommendations processing needs more time - going into the background.");
			
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
                    NSLog(@"Ran out of time. Pausing queue.");
                    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                    self.backgroundTask = UIBackgroundTaskInvalid;
                }
            }];
			
            dispatch_queue_t taskcompletion = dispatch_get_global_queue(
																		DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			
			dispatch_async(taskcompletion, ^{
				NSLog(@"Emptying operation queues...");
                if(self.backgroundTask != UIBackgroundTaskInvalid) {
                    [self.processingQueue waitUntilAllOperationsAreFinished];    
					NSLog(@"operation queues are finished!");
                    if(self.backgroundTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    } else {
                        NSLog(@"App came to foreground in the meantime");
                    }
                }
            });
        }
	}
    
    // if the user kills the app while we are performing background tasks the 
    // DidEnterBackground notification is called again, so we disable it and 
    // enable it in the foreground
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];        
}

- (void)enterForeground
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(enterBackground) 
                                                 name:UIApplicationDidEnterBackgroundNotification 
                                               object:nil];	
    
	NSLog(@"Entering foreground - quitting background task.");
	if(self.backgroundTask != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
		self.backgroundTask = UIBackgroundTaskInvalid;
	}		
}

#pragma mark - Class methods

+ (SCHRecommendationManager *)sharedManager
{
    if (sharedManager == nil) {
		sharedManager = [[SCHRecommendationManager alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterBackground) 
													 name:UIApplicationDidEnterBackgroundNotification 
												   object:nil];			
		
		[[NSNotificationCenter defaultCenter] addObserver:sharedManager 
												 selector:@selector(enterForeground) 
													 name:UIApplicationWillEnterForegroundNotification 
												   object:nil];	
    } 
	
	return sharedManager;
}

@end
