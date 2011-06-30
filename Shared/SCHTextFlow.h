//
//  SCHTextFlow.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBTextFlow.h"

@class SCHXPSProvider;
@class SCHBookIdentifier;
@class NSManagedObjectContext;

@interface SCHTextFlow : KNFBTextFlow {
    
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc;

@property (nonatomic, retain) SCHXPSProvider *xpsProvider;

@end
