//
//  SCHISBNItemObject.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHISBNItem.h"

@interface SCHISBNItemObject : NSObject  <SCHISBNItem>

@property (nonatomic, retain) NSNumber *DRMQualifier;
@property (nonatomic, retain) NSNumber *ContentIdentifierType;
@property (nonatomic, copy)   NSString *ContentIdentifier;
@property (nonatomic, assign) BOOL coverURLOnly;

@end
