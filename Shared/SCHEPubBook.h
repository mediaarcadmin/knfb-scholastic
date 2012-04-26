//
//  SCHEPubBook.h
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHEPubBookmarkPointTranslation.h"
#import <libEucalyptus/EucEPubBook.h>

@class SCHBookIdentifier;

@interface SCHEPubBook : EucEPubBook <SCHEPubBookmarkPointTranslation> {}

@property (nonatomic, retain, readonly) SCHBookIdentifier *identifier;

- (id)initWithBookIdentifier:(SCHBookIdentifier *)identifier managedObjectContext:(NSManagedObjectContext *)moc;

@end
