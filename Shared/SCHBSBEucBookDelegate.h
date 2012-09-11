//
//  SCHBSBEucBookDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 31/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#if !BRANCHING_STORIES_DISABLED

@class SCHBSBEucBook;
@class EucBookPageIndexPoint;

@protocol SCHBSBEucBookDelegate <NSObject>

@required
- (void)bookWillShrink:(SCHBSBEucBook *)book;
- (void)book:(SCHBSBEucBook *)book hasShrunkToIndexPoint:(EucBookPageIndexPoint *)indexPoint;
- (void)book:(SCHBSBEucBook *)book hasGrownToIndexPoint:(EucBookPageIndexPoint *)indexPoint;

@end
#endif