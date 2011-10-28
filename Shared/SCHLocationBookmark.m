//
//  SCHLocationBookmark.m
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHLocationBookmark.h"
#import "SCHBookmark.h"

// Constants
NSString * const kSCHLocationBookmark = @"SCHLocationBookmark";

@implementation SCHLocationBookmark
@dynamic Page;
@dynamic Bookmark;

- (void)setInitialValues
{
    self.Page = [NSNumber numberWithInteger:0];
}

@end
