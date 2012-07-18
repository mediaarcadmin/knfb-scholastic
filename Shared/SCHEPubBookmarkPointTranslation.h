//
//  SCHEPubBookmarkPointTranslation.h
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <libEucalyptus/EucBookPageIndexPoint.h>
#import "SCHBookPoint.h"

@protocol SCHEPubBookmarkPointTranslation <NSObject>

- (SCHBookPoint *)bookPointFromBookPageIndexPoint:(EucBookPageIndexPoint *)indexPoint;
- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint;

@end
