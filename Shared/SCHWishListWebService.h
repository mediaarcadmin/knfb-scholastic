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

- (BOOL)getWishListItems:(NSArray *)profileIDs;
- (BOOL)addItemsToWishList:(NSArray *)wishListItems;
- (BOOL)deleteWishListItems:(NSArray *)wishListItems;
- (BOOL)deleteWishList:(NSArray *)wishListProfiles;

@end
