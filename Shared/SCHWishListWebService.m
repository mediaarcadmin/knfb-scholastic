//
//  SCHWishListWebService.m
//  Scholastic
//
//  Created by John Eddie on 22/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListWebService.h"

#import "BITAPIError.h"
#import "BITNetworkActivityManager.h"
#import "SCHWishListConstants.h"
#import "SCHAuthenticationManager.h"
#import "SCHUserDefaults.h"
#import "WishListServiceSvc+Binding.h"

static NSString * const kSCHWishListWebServiceUndefinedMethod = @"undefined method";

static NSString * const kSCHWishListWebServiceClientID = @"KNFB";

/*
 * This class is thread safe when using the Thread Confinement design pattern.
 */

@interface SCHWishListWebService ()

@property (nonatomic, retain) WishListServiceSoap11Binding *binding;

- (NSString *)methodNameFromObject:(id)anObject;

- (NSDictionary *)objectFromWishList:(ax21_WishList *)anObject;
- (NSDictionary *)objectFromWishListProfileItem:(ax21_WishListProfileItem *)anObject;
- (NSDictionary *)objectFromWishListItem:(ax21_WishListItem *)anObject;
- (NSDictionary *)objectFromWishListProfile:(ax21_WishListProfile *)anObject;
- (NSDictionary *)objectFromWishListStatus:(ax21_WishListStatus *)anObject;
- (NSDictionary *)objectFromWishListProfileStatus:(ax21_WishListProfileStatus *)anObject;
- (NSDictionary *)objectFromWishListItemStatus:(ax21_WishListItemStatus *)anObject;
- (NSDictionary *)objectFromWishListError:(ax21_WishListError *)anObject;

- (id)objectFromTranslate:(id)anObject;

- (void)fromObject:(NSDictionary *)object intoWishListProfileItem:(ax21_WishListProfileItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoWishListItem:(ax21_WishListItem *)intoObject;
- (void)fromObject:(NSDictionary *)object intoWishListProfile:(ax21_WishListProfile *)intoObject;

@end

@implementation SCHWishListWebService

@synthesize binding;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		binding = [[WishListServiceSvc SCHWishListServiceSoap11Binding] retain];
		binding.logXMLInOut = NO;		
	}
	
	return(self);
}

- (void)dealloc
{
    [binding clearBindingOperations]; // Will invalidate the delegate on any underway operations
	[binding release], binding = nil;
	
	[super dealloc];
}

- (void)clear
{
    self.binding = [WishListServiceSvc SCHWishListServiceSoap11Binding];
    binding.logXMLInOut = NO;		
}

#pragma mark - API Proxy methods

- (BOOL)getWishListItems:(NSArray *)profileIDs
{
    BOOL ret = NO;
    
    if ([SCHAuthenticationManager sharedAuthenticationManager].pToken != nil) {
        WishListServiceSvc_GetWishListItems *request = [WishListServiceSvc_GetWishListItems new];
        
        request.clientID = kSCHWishListWebServiceClientID;
        request.spsIdParam = nil;
        request.token = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
        for (id profileID in profileIDs) {
            [request addProfileIdList:profileID];
        }
        
        [self.binding GetWishListItemsAsyncUsingParameters:request delegate:self]; 
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
        
        [request release], request = nil;
        ret = YES;
    }
    
    return ret;
}

- (BOOL)addItemsToWishList:(NSArray *)wishListItems
{
    BOOL ret = NO;
    
    if ([SCHAuthenticationManager sharedAuthenticationManager].pToken != nil) {
        WishListServiceSvc_AddItemsToWishList *request = [WishListServiceSvc_AddItemsToWishList new];
        
        request.clientID = kSCHWishListWebServiceClientID;
        request.spsIdParam = nil;
        request.token = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
        ax21_WishListProfileItem *wishListProfileItem = nil;
        for (id item in wishListItems) {
            wishListProfileItem = [[ax21_WishListProfileItem alloc] init];
            [self fromObject:item intoObject:wishListProfileItem];		
            [request addProfileItemList:wishListProfileItem];
            [wishListProfileItem release], wishListProfileItem = nil;
        }
        
        [self.binding AddItemsToWishListAsyncUsingParameters:request delegate:self]; 
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
        
        [request release], request = nil;
		ret = YES;
	}
	
	return ret;        
}

- (BOOL)deleteWishListItems:(NSArray *)wishListItems
{
    BOOL ret = NO;
    
    if ([SCHAuthenticationManager sharedAuthenticationManager].pToken != nil) {
        WishListServiceSvc_DeleteWishListItems *request = [WishListServiceSvc_DeleteWishListItems new];
        
        request.clientID = kSCHWishListWebServiceClientID;
        request.spsIdParam = nil;
        request.token = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
        ax21_WishListProfileItem *wishListProfileItem = nil;
        for (id item in wishListItems) {
            wishListProfileItem = [[ax21_WishListProfileItem alloc] init];
            [self fromObject:item intoObject:wishListProfileItem];		
            [request addProfileItemList:wishListProfileItem];
            [wishListProfileItem release], wishListProfileItem = nil;
        }
        
        [self.binding DeleteWishListItemsAsyncUsingParameters:request delegate:self]; 
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
        
        [request release], request = nil;
        ret = YES;
	}
	
	return ret;        
}

- (BOOL)deleteWishList:(NSArray *)wishListProfiles
{
    BOOL ret = NO;
    
    if ([SCHAuthenticationManager sharedAuthenticationManager].pToken != nil) {
        WishListServiceSvc_DeleteWishList *request = [WishListServiceSvc_DeleteWishList new];
        
        request.clientID = kSCHWishListWebServiceClientID;
        request.spsIdParam = nil;
        request.token = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
        ax21_WishListProfile *wishListProfile = nil;
        for (id profile in wishListProfiles) {
            wishListProfile = [[ax21_WishListProfile alloc] init];
            [self fromObject:profile intoObject:wishListProfile];		
            [request addProfileIdList:wishListProfile];
            [wishListProfile release], wishListProfile = nil;
        }
        
        [self.binding DeleteWishListAsyncUsingParameters:request delegate:self]; 
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
        
        [request release], request = nil;
        ret = YES;
	}
	
	return ret;                
}

#pragma mark - LibreAccessServiceSoap12BindingResponse Delegate methods

- (void)operation:(WishListServiceSoap11BindingOperation *)operation completedWithResponse:(WishListServiceSoap11BindingResponse *)response
{	
	[[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
	// just in case we have a stray operation make sure it's bound to the current binding
    if (self.binding == operation.binding ) {
        NSString *methodName = [self methodNameFromObject:operation];
        
        if (operation.response.error != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(method:didFailWithError:requestInfo:result:)]) {
                [(id)self.delegate method:methodName didFailWithError:[self confirmErrorDomain:operation.response.error 
                                                                                 forDomainName:@"WishListServiceSoap11BindingResponseHTTP"]
                              requestInfo:nil result:nil];
            }
        } else {
            for (id bodyPart in response.bodyParts) {
                if ([bodyPart isKindOfClass:[SOAPFault class]]) {
                    [self reportFault:(SOAPFault *)bodyPart forMethod:methodName 
                          requestInfo:nil];
                    continue;
                }
                
                NSDate *serverDate = [self.rfc822DateFormatter dateFromString:[operation.responseHeaders objectForKey:@"Date"]];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:(double)operation.serverDateDelta], @"serverDateDelta",
                                          (serverDate == nil ? (id)[NSNull null] : serverDate), @"serverDate",
                                          nil];
                
                if([(id)self.delegate respondsToSelector:@selector(method:didCompleteWithResult:userInfo:)]) {
                    [(id)self.delegate method:methodName didCompleteWithResult:[self objectFrom:bodyPart] 
                                     userInfo:userInfo];									
                }
            }		
        }
    }     
}

- (NSString *)methodNameFromObject:(id)anObject
{
	NSString *ret = kSCHWishListWebServiceUndefinedMethod;
	
	if (anObject != nil) {
		if([anObject isKindOfClass:[WishListServiceSvc_GetWishListItems class]] == YES ||
		   [anObject isKindOfClass:[WishListServiceSvc_GetWishListItemsResponse class]] == YES ||		   
		   [anObject isKindOfClass:[WishListServiceSoap11Binding_GetWishListItems class]] == YES) {
			ret = kSCHWishListWebServiceGetWishListItems;	
		} else if([anObject isKindOfClass:[WishListServiceSvc_AddItemsToWishList class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSvc_AddItemsToWishListResponse class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSoap11Binding_AddItemsToWishList class]] == YES) {
			ret = kSCHWishListWebServiceAddItemsToWishList;	
		} else if([anObject isKindOfClass:[WishListServiceSvc_DeleteWishListItems class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSvc_DeleteWishListItemsResponse class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSoap11Binding_DeleteWishListItems class]] == YES) {
			ret = kSCHWishListWebServiceDeleteWishListItems;	
		} else if([anObject isKindOfClass:[WishListServiceSvc_DeleteWishList class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSvc_DeleteWishListResponse class]] == YES ||
				  [anObject isKindOfClass:[WishListServiceSoap11Binding_DeleteWishList class]] == YES) {
			ret = kSCHWishListWebServiceDeleteWishList;	
        }
	}
	
	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper Protocol methods 

- (NSDictionary *)objectFrom:(id)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		if ([anObject isKindOfClass:[WishListServiceSvc_GetWishListItemsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[anObject return_]] forKey:kSCHWishListWebServiceGetWishListItems];
		} else if ([anObject isKindOfClass:[WishListServiceSvc_AddItemsToWishListResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[anObject return_]] forKey:kSCHWishListWebServiceAddItemsToWishList];
		} else if ([anObject isKindOfClass:[WishListServiceSvc_DeleteWishListItemsResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[anObject return_]] forKey:kSCHWishListWebServiceDeleteWishListItems];
		} else if ([anObject isKindOfClass:[WishListServiceSvc_DeleteWishListResponse class]] == YES) {
			ret = [NSDictionary dictionaryWithObject:[self objectFromTranslate:[anObject return_]] forKey:kSCHWishListWebServiceDeleteWishList];            
		}
        
	}
	
	return(ret);
}

- (void)fromObject:(NSDictionary *)object intoObject:(id)intoObject
{
	if (object != nil && intoObject != nil) {
		if ([intoObject isKindOfClass:[ax21_WishListProfileItem class]] == YES) {
			[self fromObject:object intoWishListProfileItem:intoObject];
		} else if ([intoObject isKindOfClass:[ax21_WishListProfile class]] == YES) {
			[self fromObject:object intoWishListProfile:intoObject];
        }
	}
}

#pragma mark -
#pragma mark ObjectMapper objectFrom: converter methods 

- (NSDictionary *)objectFromWishList:(ax21_WishList *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileItemList] forKey:kSCHWishListWebServiceProfileItemList];
		[objects setObject:[self objectFromTranslate:anObject.spsID] forKey:kSCHWishListWebServicespsID];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListProfileItem:(ax21_WishListProfileItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.itemList] forKey:kSCHWishListWebServiceItemList];
		[objects setObject:[self objectFromTranslate:anObject.profile] forKey:kSCHWishListWebServiceProfile];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListItem:(ax21_WishListItem *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.author] forKey:kSCHWishListWebServiceAuthor];
		[objects setObject:[self objectFromTranslate:anObject.initiatedBy.value] forKey:kSCHWishListWebServiceInitiatedBy];
		[objects setObject:[self objectFromTranslate:anObject.isbn] forKey:kSCHWishListWebServiceISBN];
		[objects setObject:[self objectFromTranslate:anObject.timeStamp] forKey:kSCHWishListWebServiceTimestamp];
        [objects setObject:[self objectFromTranslate:anObject.title] forKey:kSCHWishListWebServiceTitle]; 
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListProfile:(ax21_WishListProfile *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHWishListWebServiceProfileID];
		[objects setObject:[self objectFromTranslate:anObject.profileName] forKey:kSCHWishListWebServiceProfileName];
		[objects setObject:[self objectFromTranslate:anObject.timestamp] forKey:kSCHWishListWebServiceTimestamp];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListStatus:(ax21_WishListStatus *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.profileStatusList] forKey:kSCHWishListWebServiceProfileStatusList];
        [objects setObject:[self objectFromTranslate:anObject.spsID] forKey:kSCHWishListWebServicespsID];
		[objects setObject:[self objectFromTranslate:anObject.wishListError] forKey:kSCHWishListWebServiceWishListError];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListProfileStatus:(ax21_WishListProfileStatus *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.itemStatusList] forKey:kSCHWishListWebServiceItemStatusList];
        [objects setObject:[self objectFromTranslate:anObject.profileError] forKey:kSCHWishListWebServiceProfileError];
		[objects setObject:[self objectFromTranslate:anObject.profileID] forKey:kSCHWishListWebServiceProfileID];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListItemStatus:(ax21_WishListItemStatus *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.isbn] forKey:kSCHWishListWebServiceISBN];
		[objects setObject:[self objectFromTranslate:anObject.itemError] forKey:kSCHWishListWebServiceWishListError];
        
		ret = objects;				
	}
	
	return(ret);
}

- (NSDictionary *)objectFromWishListError:(ax21_WishListError *)anObject
{
	NSDictionary *ret = nil;
	
	if (anObject != nil) {
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		[objects setObject:[self objectFromTranslate:anObject.errorCode] forKey:kSCHWishListWebServiceErrorCode];
		[objects setObject:[self objectFromTranslate:anObject.errorMessage] forKey:kSCHWishListWebServiceErrorMessage];
        
		ret = objects;				
	}
	
	return(ret);
}

- (id)objectFromTranslate:(id)anObject
{
	id ret = nil;
	
	if (anObject == nil) {
		ret = [NSNull null];
	} else if([anObject isKindOfClass:[NSMutableArray class]] == YES) {
		ret = [NSMutableArray array];
		
		if ([(NSMutableArray *)anObject count] > 0) {
			id firstItem = [anObject objectAtIndex:0];
			
			if ([firstItem isKindOfClass:[ax21_WishListProfileItem class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromWishListProfileItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[ax21_WishListItem class]] == YES) {
				for (id item in anObject) {				
					[ret addObject:[self objectFromWishListItem:item]];					
				}
			} else if ([firstItem isKindOfClass:[ax21_WishListProfileStatus class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromWishListProfileStatus:item]];					
				}
			} else if ([firstItem isKindOfClass:[ax21_WishListItemStatus class]] == YES) {
				for (id item in anObject) {
					[ret addObject:[self objectFromWishListItemStatus:item]];					
				}
            }
        }		
	} else if([anObject isKindOfClass:[USBoolean class]] == YES) {
		ret = [NSNumber numberWithBool:[anObject boolValue]];
    } else if ([anObject isKindOfClass:[ax21_WishList class]] == YES) {
        ret = [self objectFromWishList:anObject];	
    } else if ([anObject isKindOfClass:[ax21_WishListProfile class]] == YES) {
        ret = [self objectFromWishListProfile:anObject];	        
    } else if ([anObject isKindOfClass:[ax21_WishListItemStatus class]] == YES) {
        ret = [self objectFromWishListItemStatus:anObject];	
    } else if ([anObject isKindOfClass:[ax21_WishListStatus class]] == YES) {
        ret = [self objectFromWishListStatus:anObject];	                        
    } else if ([anObject isKindOfClass:[ax21_WishListError class]] == YES) {
        ret = [self objectFromWishListError:anObject];	                
	} else {
		ret = anObject;
	}
    
	return(ret);
}

#pragma mark -
#pragma mark ObjectMapper fromObject: converter methods 

- (void)fromObject:(NSDictionary *)object intoWishListProfileItem:(ax21_WishListProfileItem *)intoObject
{
	if (object != nil && intoObject != nil) {
        ax21_WishListItem *wishListItem = nil;
        for (NSDictionary *item in [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceItemList]]) {
            wishListItem = [[ax21_WishListItem alloc] init];
            [self fromObject:item intoWishListItem:wishListItem];
            [intoObject addItemList:wishListItem];
            [wishListItem release], wishListItem = nil;
        }
        id wishListProfile = [[ax21_WishListProfile alloc] init];
        intoObject.profile = wishListProfile;
        [wishListProfile release], wishListProfile = nil;
		[self fromObject:object intoWishListProfile:intoObject.profile];
	}
}

- (void)fromObject:(NSDictionary *)object intoWishListItem:(ax21_WishListItem *)intoObject
{
    if (object != nil && intoObject != nil) {
        intoObject.author = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceAuthor]];
        ax21_InitiatedByEnum *initiatedByEnum = [[ax21_InitiatedByEnum alloc] init];
        initiatedByEnum.value = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceInitiatedBy]];
        intoObject.initiatedBy = initiatedByEnum;
        [initiatedByEnum release], initiatedByEnum = nil;
        intoObject.isbn = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceISBN]];
        intoObject.timeStamp = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceTimestamp]];
        intoObject.title = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceTitle]];        
    }
}

- (void)fromObject:(NSDictionary *)object intoWishListProfile:(ax21_WishListProfile *)intoObject
{
	if (object != nil && intoObject != nil) {
		intoObject.profileID = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceProfileID]];
		intoObject.profileName = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceProfileName]];
		intoObject.timestamp = [self fromObjectTranslate:[object valueForKey:kSCHWishListWebServiceTimestamp]];        
	}
}

@end
