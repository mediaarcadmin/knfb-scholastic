//
//  SCHBSBEucBook.h
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <libEucalyptus/EucBook.h>
#import "SCHEucBookmarkPointTranslation.h"

@class EucBookIndex, EucBookNavPoint, EucBookPageIndexPoint, EucBookPageIndexPointRange;
@class SCHBookIdentifier;

@interface SCHBSBEucBook : NSObject <EucBook, SCHEucBookmarkPointTranslation>

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc;

@end