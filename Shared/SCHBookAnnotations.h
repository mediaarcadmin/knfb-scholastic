//
//  SCHBookAnnotations.h
//  Scholastic
//
//  Created by John S. Eddie on 04/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHPrivateAnnotations;
@class SCHFavorite;
@class SCHLastPage;

@interface SCHBookAnnotations : NSObject 
{    
}

- (id)initWithPrivateAnnotations:(SCHPrivateAnnotations *)privateAnnotations;

- (NSArray *)bookmarks;
- (NSArray *)highlightsForPage:(NSUInteger)page;
- (NSArray *)notes;
- (SCHFavorite *)favorite;
- (SCHLastPage *)lastPage;

@end
