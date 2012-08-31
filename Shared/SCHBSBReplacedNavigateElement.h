//
//  SCHBSBReplacedNavigateElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementPlaceholder.h"

@interface SCHBSBReplacedNavigateElement : SCHBSBReplacedElementPlaceholder

- (id)initWithPointSize:(CGFloat)point label:(NSString *)navigateLabel targetNode:(NSString *)navigateTarget;

@end
