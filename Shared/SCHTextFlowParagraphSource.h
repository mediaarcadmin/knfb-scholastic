//
//  SCHTextFlowParagraphSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 02/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBTextFlowParagraphSource.h"
#import "KNFBParagraphSource.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;

@interface SCHTextFlowParagraphSource : KNFBTextFlowParagraphSource <KNFBParagraphSource> {}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)identifier managedObjectContext:(NSManagedObjectContext *)moc;

@end
