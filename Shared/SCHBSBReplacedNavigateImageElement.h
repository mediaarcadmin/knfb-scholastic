//
//  SCHBSBReplacedNavigateImageElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElement.h"

@interface SCHBSBReplacedNavigateImageElement : SCHBSBReplacedElement

- (id)initWithImage:(UIImage *)image targetNode:(NSString *)navigateTarget binding:(NSString *)binding value:(NSString *)aValue;

@end
