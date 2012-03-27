//
//  WishListServiceSvc+Binding.m
//  Scholastic
//
//  Created by John Eddie on 27/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "WishListServiceSvc+Binding.h"

@implementation WishListServiceSvc (Binding)

+ (WishListServiceSoap11Binding *)SCHWishListServiceSoap11Binding
{
    NSLog(@"WishListServiceSoap using: %@", WISHLIST_SERVER_ENDPOINT);
    return [[[WishListServiceSoap11Binding alloc] initWithAddress:WISHLIST_SERVER_ENDPOINT] autorelease];
}

@end
