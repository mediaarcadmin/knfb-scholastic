//
//  SCHEPubToTextFlowMappingParagraphSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "KNFBParagraphSource.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;

@interface SCHEPubToTextFlowMappingParagraphSource : NSObject <KNFBParagraphSource> {}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)identifier managedObjectContext:(NSManagedObjectContext *)moc;

@end
