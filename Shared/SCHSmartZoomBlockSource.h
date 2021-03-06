//
//  SCHSmartZoomBlockSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 13/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBSmartZoomBlockSource.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;

@interface SCHSmartZoomBlockSource : KNFBSmartZoomBlockSource {
    
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
