//
//  SCHWishListWebService.h
//  Scholastic
//
//  Created by John Eddie on 22/02/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSOAPProxy.h"

#import "WishListServiceSvc.h"
#import "BITObjectMapperProtocol.h"

@interface SCHWishListWebService : BITSOAPProxy <WishListServiceSoap11BindingResponseDelegate, BITObjectMapperProtocol> 

- (void)clear;

- (void)getWishListItems:(NSString *)pToken profiles:(NSArray *)profileIDs;
- (void)addItemsToWishList:(NSString *)pToken wishListItems:(NSArray *)wishListItems;
- (void)deleteWishListItems:(NSString *)pToken wishListItems:(NSArray *)wishListItems;
- (void)deleteWishList:(NSString *)pToken wishListProfiles:(NSArray *)wishListProfiles;

@end
