//
//  SCHSettingsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "NSManagedObjectContext+Extensions.h"

#import "SCHLibreAccessWebService.h"
#import "SCHSettingItem.h"
#import "BITAPIError.h"

// Constants
NSString * const SCHSettingsSyncComponentDidCompleteNotification = @"SCHSettingsSyncComponentDidCompleteNotification";
NSString * const SCHSettingsSyncComponentDidFailNotification = @"SCHSettingsSyncComponentDidFailNotification";

@interface SCHSettingsSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (nonatomic, retain) NSManagedObjectContext *backgroundThreadManagedObjectContext;

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext;
- (void)updateUserSettings:(NSArray *)settingsList;
- (void)backgroundSave:(BOOL)batch;

@end

@implementation SCHSettingsSyncComponent

@synthesize libreAccessWebService;
@synthesize backgroundThreadManagedObjectContext;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    [backgroundThreadManagedObjectContext release], backgroundThreadManagedObjectContext = nil;
    
	[super dealloc];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
		
		self.isSynchronizing = [self.libreAccessWebService listUserSettings];
		if (self.isSynchronizing == NO) {
			[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode){
                if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                    [self.delegate authenticationDidSucceed];
                } else {
                    self.isSynchronizing = NO;
                }
            } failureBlock:^(NSError *error){
                self.isSynchronizing = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSyncComponentDidFailAuthenticationNotification
                                                                    object:self];                
            }];				
			ret = NO;
		}

        if (ret == NO) {
            [self endBackgroundTask];
        }         
	}
	
	return(ret);	
}

#pragma - Overrideen methods used by resetSync

- (void)resetWebService
{
    [self.libreAccessWebService clear];    
}

- (void)clearComponent
{
    // nop
}

- (void)clearCoreData
{
    [self clearCoreDataUsingContext:self.managedObjectContext];
}

- (void)clearCoreDataUsingContext:(NSManagedObjectContext *)aManagedObjectContext
{
	NSError *error = nil;
	
	if (![aManagedObjectContext BITemptyEntity:kSCHSettingItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result 
      userInfo:(NSDictionary *)userInfo
{	
    @try {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
            self.backgroundThreadManagedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [self.backgroundThreadManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
            
            [self updateUserSettings:[result objectForKey:kSCHLibreAccessWebServiceUserSettingsList]];
            
            [self backgroundSave:NO];
            self.backgroundThreadManagedObjectContext = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidCompleteNotification object:self];			
                [super method:method didCompleteWithResult:nil userInfo:userInfo];	
            });                
        });                                                        
    }
    @catch (NSException *exception) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
                                                            object:self];        
        NSError *error = [NSError errorWithDomain:kBITAPIErrorDomain 
                                             code:kBITAPIExceptionError 
                                         userInfo:[NSDictionary dictionaryWithObject:[exception reason]
                                                                              forKey:NSLocalizedDescriptionKey]];
        [super method:method didFailWithError:error requestInfo:nil result:result];
    }
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCHSettingsSyncComponentDidFailNotification 
                                                        object:self];        
    [super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

- (void)updateUserSettings:(NSArray *)settingsList
{	
    NSAssert([NSThread isMainThread] == NO, @"updateUserSettings MUST NOT be executed on the main thread");        
    if ([settingsList count] > 0) {
        [self clearCoreDataUsingContext:self.backgroundThreadManagedObjectContext];
        
        for (id setting in settingsList) {
            SCHSettingItem *newUserSettingsItem = [NSEntityDescription insertNewObjectForEntityForName:kSCHSettingItem 
                                                                                inManagedObjectContext:self.backgroundThreadManagedObjectContext];
            
            newUserSettingsItem.SettingName = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingName]];
            newUserSettingsItem.SettingValue = [self makeNullNil:[setting objectForKey:kSCHLibreAccessWebServiceSettingValue]];
        }
        
        [self backgroundSave:NO];
    }
}

- (void)backgroundSave:(BOOL)batch
{
    NSAssert([NSThread isMainThread] == NO, @"backgroundSave MUST NOT be executed on the main thread");
    
    NSError *error = nil;
    static NSUInteger batchCount = 0;
    
    if (batch == NO || ++batchCount > 250) {
        batchCount = 0;
        if ([self.backgroundThreadManagedObjectContext hasChanges] == YES &&
            ![self.backgroundThreadManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}

@end
