//
//  SCHBookStoryInteractions+XPS.h
//  Scholastic
//
//  Created by Neil Gall on 03/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHBookStoryInteractions.h"

@class SCHXPSProvider;

// The methods dependent on SCHXPSProvider are placed in this category to break
// this dependency for the unit test target.

@interface SCHBookStoryInteractions (XPS)

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider
           oddPagesOnLeft:(BOOL)oddPagesOnLeft
                 delegate:(id<SCHBookStoryInteractionsDelegate>)delegate;

@end
