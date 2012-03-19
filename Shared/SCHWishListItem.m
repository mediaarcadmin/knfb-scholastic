//
//  SCHWishListItem.m
//  Scholastic
//
//  Created by John Eddie on 02/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHWishListItem.h"
#import "SCHWishListProfile.h"

// Constants
NSString * const kSCHWishListItem = @"SCHWishListItem";

@implementation SCHWishListItem

@dynamic Author;
@dynamic InitiatedBy;
@dynamic ISBN;
@dynamic Timestamp;
@dynamic Title;
@dynamic WishListProfile;

- (UIImage *)bookCover
{
    // FIXME: return a real image at some point...
    return [UIImage imageNamed:@"sampleCoverImage.jpg"];
}

@end
