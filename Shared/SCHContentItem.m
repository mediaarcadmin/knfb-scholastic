// 
//  SCHContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHContentItem.h"
#import "SCHBookIdentifier.h"

@implementation SCHContentItem 

@dynamic DRMQualifier;
@dynamic ContentIdentifierType;
@dynamic ContentIdentifier;

- (SCHBookIdentifier *)bookIdentifier
{
    SCHBookIdentifier *identifier = [[SCHBookIdentifier alloc] initWithISBN:self.ContentIdentifier
                                                               DRMQualifier:self.DRMQualifier];
    return [identifier autorelease];
}

#pragma SCHISBNItem protocol methods

- (BOOL)coverURLOnly
{
    return NO;
}

@end
