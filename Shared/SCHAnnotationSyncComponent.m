//
//  SCHAnnotationSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAnnotationSyncComponent.h"
#import "SCHSyncComponentProtected.h"

#import "NSManagedObjectContext+Extensions.h"

#import "SCHAnnotationsItem.h"
#import "SCHAnnotationsContentItem.h"
#import "SCHPrivateAnnotations.h"
#import "SCHAnnotation.h"
#import "SCHAppStateManager.h"
#import "SCHBookIdentifier.h"
#import "BITAPIError.h"
#import "SCHLibreAccessWebService.h"
#import "SCHSaveProfileContentAnnotationsOperation.h"
#import "SCHListProfileContentAnnotationsOperation.h"

// Constants
NSString * const SCHAnnotationSyncComponentDidCompleteNotification = @"SCHAnnotationSyncComponentDidCompleteNotification";
NSString * const SCHAnnotationSyncComponentDidFailNotification = @"SCHAnnotationSyncComponentDidFailNotification";
NSString * const SCHAnnotationSyncComponentProfileIDs = @"SCHAnnotationSyncComponentProfileIDs";

@interface SCHAnnotationSyncComponent ()

@property (nonatomic, retain) SCHLibreAccessWebService *libreAccessWebService;
@property (atomic, retain) NSMutableDictionary *annotations;

- (NSNumber *)currentProfile;
- (BOOL)updateProfileContentAnnotations;
- (void)trackAnnotationSaves:(NSSet *)annotationsArray;
- (NSArray *)localModifiedAnnotationsItemForProfile:(NSNumber *)profileID;

@end

@implementation SCHAnnotationSyncComponent

@synthesize libreAccessWebService;
@synthesize annotations;
@synthesize savedAnnotations;
@synthesize lastSyncSaveCalled;

- (id)init
{
	self = [super init];
	if (self != nil) {
		libreAccessWebService = [[SCHLibreAccessWebService alloc] init];	
		libreAccessWebService.delegate = self;
        
		annotations = [[NSMutableDictionary dictionary] retain];
		savedAnnotations = [[NSMutableArray array] retain];
	}
	
	return(self);
}

- (void)dealloc
{
    libreAccessWebService.delegate = nil;
	[libreAccessWebService release], libreAccessWebService = nil;
    
	[annotations release], annotations = nil;
    [savedAnnotations release], savedAnnotations = nil;
    [lastSyncSaveCalled release], lastSyncSaveCalled = nil;
    
	[super dealloc];
}

- (void)addProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (profileID != nil && books != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.annotations objectForKey:profileID]; 
        if (profileBooks != nil) {
            // Only add books that do not already exist
            for (NSDictionary *book in books) {
                SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithObject:book];
                if (bookIdentifier != nil) {
                    __block BOOL bookAlreadyExists = NO;
                    [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                        if (profileBookIdentifier != nil &&
                            [bookIdentifier isEqual:profileBookIdentifier] == YES) {
                            bookAlreadyExists = YES;
                            *stop = YES;
                        }
                        [profileBookIdentifier release], profileBookIdentifier = nil;                    
                    }];
                    [bookIdentifier release], bookIdentifier = nil;
                    
                    if (bookAlreadyExists == NO) {
                        [profileBooks addObject:book];
                    }
                }
            }
        } else {
            [self.annotations setObject:[NSMutableArray arrayWithArray:books] forKey:profileID];		
        }
	}
}

// books is an array of BookIdentifiers
- (void)removeProfile:(NSNumber *)profileID withBooks:(NSArray *)books
{
	if (self.isSynchronizing == NO && profileID != nil && [books count] > 0) {
        NSMutableArray *profileBooks = [self.annotations objectForKey:profileID];
        if (profileBooks != nil) {
            for (SCHBookIdentifier *bookIdentifier in books) {
                __block NSUInteger removeBook = NSUIntegerMax;
                [profileBooks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    SCHBookIdentifier *profileBookIdentifier = [[SCHBookIdentifier alloc] initWithObject:obj];
                    if (profileBookIdentifier != nil &&
                        [bookIdentifier isEqual:profileBookIdentifier] == YES) {
                        removeBook = idx;
                        *stop = YES;
                    }
                    [profileBookIdentifier release], profileBookIdentifier = nil;                    
                }];
                if (removeBook != NSUIntegerMax && removeBook < [profileBooks count]) {
                    [profileBooks removeObjectAtIndex:removeBook];   
                }
            }
            if ([profileBooks count] < 1) {
                [self.annotations removeObjectForKey:profileID];
            }
        }
	}
}

- (BOOL)haveProfiles
{
	return([self.annotations count ] > 0);
}

- (NSNumber *)currentProfile
{
    NSNumber *ret = nil;
    
    if ([self haveProfiles] == YES && [self.annotations count] > 0) {
        ret = [[[self.annotations allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];    
    }
    
    return ret;
}

- (BOOL)nextProfile
{
    NSNumber *currentProfile = [self currentProfile];
   
    if (currentProfile != nil) {
        [self.annotations removeObjectForKey:currentProfile];    
    }
    [self clearFailures];
    
    return [self haveProfiles];
}

- (BOOL)synchronize
{
	BOOL ret = YES;
	
	if (self.isSynchronizing == NO) {
        [self beginBackgroundTask];
        
		ret = [self updateProfileContentAnnotations];
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
    [self.annotations removeAllObjects];
    [self.savedAnnotations removeAllObjects];
    self.lastSyncSaveCalled = nil;    
}

- (void)clearCoreData
{
	NSError *error = nil;
	    
	if (![self.managedObjectContext BITemptyEntity:kSCHAnnotationsItem error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}	    
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{
    NSNumber *profileID = [self currentProfile];
    
    if (profileID != nil) {
        if([method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings] == NSOrderedSame) {
            SCHSaveProfileContentAnnotationsOperation *operation = [[[SCHSaveProfileContentAnnotationsOperation alloc] initWithSyncComponent:self
                                                                                                                                      result:result
                                                                                                                                    userInfo:userInfo] autorelease];
            operation.profileID = profileID;
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];
        } else if([method compare:kSCHLibreAccessWebServiceListProfileContentAnnotationsForRatings] == NSOrderedSame) {
            SCHListProfileContentAnnotationsOperation *operation = [[[SCHListProfileContentAnnotationsOperation alloc] initWithSyncComponent:self
                                                                                                                                      result:result
                                                                                                                                    userInfo:userInfo] autorelease];
            operation.profileID = profileID;
            [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
            [self.backgroundProcessingQueue addOperation:operation];                
        }
    } else {
        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                         forKey:SCHAnnotationSyncComponentProfileIDs];                    
        [self completeWithSuccessMethod:method 
                                 result:result 
                               userInfo:nil 
                       notificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                   notificationUserInfo:notificationUserInfo];
        [self.savedAnnotations removeAllObjects];        
    }
}

// track annotations that need to be saved
- (void)trackAnnotationSaves:(NSSet *)annotationsArray
{
    for (SCHAnnotation *annotation in annotationsArray) {
        if ([annotation.Action saveActionValue] != kSCHSaveActionsNone) {
            [self.savedAnnotations addObject:[annotation objectID]];
        }
    }
}

- (BOOL)annotationIDIsValid:(NSNumber *)annotationID
{
    return [annotationID integerValue] > 0;
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo 
        result:(NSDictionary *)result
{
    NSLog(@"%@:didFailWithError\n%@", method, error);
    NSNumber *profileID = [self currentProfile];
    
    // server error so process the result
    if ([error domain] == kBITAPIErrorDomain &&
        [method compare:kSCHLibreAccessWebServiceSaveProfileContentAnnotationsForRatings] == NSOrderedSame &&	            
        profileID != nil) {
        SCHSaveProfileContentAnnotationsOperation *operation = [[[SCHSaveProfileContentAnnotationsOperation alloc] initWithSyncComponent:self
                                                                                                                                  result:result
                                                                                                                                userInfo:nil] autorelease];
        operation.profileID = profileID;
        [operation setThreadPriority:SCHSyncComponentThreadLowPriority];
        [self.backgroundProcessingQueue addOperation:operation];            
    } else {
        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                         forKey:SCHAnnotationSyncComponentProfileIDs];            
        [self completeWithFailureMethod:method 
                                  error:error 
                            requestInfo:requestInfo 
                                 result:result 
                       notificationName:SCHAnnotationSyncComponentDidFailNotification 
                   notificationUserInfo:notificationUserInfo];
        [self.savedAnnotations removeAllObjects];            
    }    
}

- (BOOL)requestListProfileContentAnnotationsForProfileID:(NSNumber *)profileID
{
    BOOL ret = YES;
    NSArray *books = [self.annotations objectForKey:profileID];
    
    if (self.saveOnly == NO && [self.annotations count] > 0) {
        self.isSynchronizing = [self.libreAccessWebService listProfileContentAnnotations:books 
                                                                              forProfile:profileID];
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
    } else {
        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                         forKey:SCHAnnotationSyncComponentProfileIDs];        
        if (profileID != nil) {
            [self.annotations removeObjectForKey:profileID];
        }
        
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                   notificationUserInfo:notificationUserInfo];
        [self.savedAnnotations removeAllObjects];        
    }
    
    return ret;
}

- (BOOL)updateProfileContentAnnotations
{
	BOOL ret = YES;
    BOOL shouldSyncNotes = NO;
	
    NSNumber *profileID = [self currentProfile];
    
    if (profileID != nil) {
        self.lastSyncSaveCalled = nil;
        [self.savedAnnotations removeAllObjects];
        NSArray *updatedAnnotations = [self localModifiedAnnotationsItemForProfile:profileID];
        if ([updatedAnnotations count] > 0) {
            shouldSyncNotes = [[SCHAppStateManager sharedAppStateManager] canSyncNotes];
            for (SCHAnnotationsItem *annotionItem in updatedAnnotations) {
                for (SCHAnnotationsContentItem *annotationContentItem in annotionItem.AnnotationsContentItem) {
                    [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Highlights];
                    if (shouldSyncNotes == YES) {
                        [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Notes];
                    }
                    [self trackAnnotationSaves:annotationContentItem.PrivateAnnotations.Bookmarks];
                }
            }
            
            self.isSynchronizing = [self.libreAccessWebService saveProfileContentAnnotations:updatedAnnotations];
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
            } else {
                self.lastSyncSaveCalled = [NSDate date];
            }
        } else {
            ret = [self requestListProfileContentAnnotationsForProfileID:profileID];    
        }
    } else {
        NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID)
                                                                         forKey:SCHAnnotationSyncComponentProfileIDs];        
        
        [self completeWithSuccessMethod:nil 
                                 result:nil 
                               userInfo:nil 
                       notificationName:SCHAnnotationSyncComponentDidCompleteNotification 
                   notificationUserInfo:notificationUserInfo];
        [self.savedAnnotations removeAllObjects];                            
    }
	
	return(ret);    
}

- (NSArray *)localModifiedAnnotationsItemForProfile:(NSNumber *)profileID
{	
    NSArray *ret = nil;
	NSError *error = nil;
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	[fetchRequest setEntity:[NSEntityDescription entityForName:kSCHAnnotationsItem inManagedObjectContext:self.managedObjectContext]];	
	NSArray *changedStates = [NSArray arrayWithObjects:[NSNumber numberWithStatus:kSCHStatusModified],
                              [NSNumber numberWithStatus:kSCHStatusDeleted], nil];
    // we don't check all the annotations as if they have changed then the last page or rating has also change
    // the resulting array will contain all books and annotations for this profile when we eventually 
    // call the annotation save it will only save books with a modified LastPage and within each book
    // annotations that have been modified
    NSPredicate *predicate = nil;
    if ([[SCHAppStateManager sharedAppStateManager] isCOPPACompliant] == YES) {
        predicate = [NSPredicate predicateWithFormat:
                     @"ProfileID == %@ AND ((ANY AnnotationsContentItem.PrivateAnnotations.LastPage.State IN %@) OR (ANY AnnotationsContentItem.PrivateAnnotations.rating.State IN %@))", 
                     profileID, changedStates, changedStates];
    } else {
        predicate = [NSPredicate predicateWithFormat:
                     @"ProfileID == %@ AND ANY AnnotationsContentItem.PrivateAnnotations.LastPage.State IN %@", 
                     profileID, changedStates];        
    }
	[fetchRequest setPredicate:predicate];
	    
	ret = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release], fetchRequest = nil;
    if (ret == nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
	
	return(ret);	
}

- (void)syncProfileContentAnnotationsCompleted:(NSNumber *)profileID 
                                   usingMethod:(NSString *)method
                                      userInfo:(NSDictionary *)userInfo
{
    NSParameterAssert(profileID);
    
    NSDictionary *notificationUserInfo = [NSDictionary dictionaryWithObject:(profileID == nil ? (id)[NSNull null] : profileID) 
                                                         forKey:SCHAnnotationSyncComponentProfileIDs];        
    if (profileID != nil) {
        [self.annotations removeObjectForKey:profileID];
    }
    
    [self completeWithSuccessMethod:method 
                             result:nil 
                           userInfo:userInfo 
                   notificationName:SCHAnnotationSyncComponentDidCompleteNotification 
               notificationUserInfo:notificationUserInfo];
    [self.savedAnnotations removeAllObjects];        
}
        
@end
