//
//  SCHFlowEucBook.h
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNFBFlowEucBook.h"

@class EucBookPageIndexPoint;
@class SCHBookPoint;

@interface SCHFlowEucBook : KNFBFlowEucBook {}

@property (nonatomic, copy, readonly) NSString *isbn;

- (id)initWithISBN:(NSString *)newIsbn;
- (id)initWithISBN:(NSString *)newIsbn failIfCachedDataNotReady:(BOOL)failIfCachedDataNotReady;
- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint;

@end
