//
//  SCHISBNItemObject.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHISBNItemObject.h"

@implementation SCHISBNItemObject

@synthesize DRMQualifier;
@synthesize ContentIdentifierType;
@synthesize ContentIdentifier;
@synthesize coverURLOnly;

- (void)dealloc
{
    [DRMQualifier release], DRMQualifier = nil;
    [ContentIdentifierType release], ContentIdentifierType = nil;
    [ContentIdentifier release], ContentIdentifier = nil;
    
    [super dealloc];
}

@end
