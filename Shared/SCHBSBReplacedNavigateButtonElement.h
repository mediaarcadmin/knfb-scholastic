//
//  SCHBSBReplacedNavigateElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElement.h"

@interface SCHBSBReplacedNavigateButtonElement : SCHBSBReplacedElement

- (id)initWithLabel:(NSString *)navigateLabel targetNode:(NSString *)navigateTarget binding:(NSString *)aBinding value:(NSString *)aValue;

@end
