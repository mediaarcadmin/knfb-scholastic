//
//  SCHFlowEucBook.h
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNFBFlowEucBook.h"
#import "SCHEucBookmarkPointTranslation.h"

@class EucBookPageIndexPoint;
@class SCHBookPoint;
@class SCHBookIdentifier;
@class NSManagedObjectContext;

@interface SCHFlowEucBook : KNFBFlowEucBook <SCHEucBookmarkPointTranslation> {}

@property (nonatomic, retain, readonly) SCHBookIdentifier *identifier;

- (id)initWithBookIdentifier:(SCHBookIdentifier *)identifier managedObjectContext:(NSManagedObjectContext *)moc;

@end
