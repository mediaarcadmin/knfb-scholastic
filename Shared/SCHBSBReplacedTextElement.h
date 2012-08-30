//
//  SCHBSBReplacedTextElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementPlaceholder.h"

@interface SCHBSBReplacedTextElement : SCHBSBReplacedElementPlaceholder

- (id)initWithPointSize:(CGFloat)point binding:(NSString *)textBinding value:(NSString *)value;

@end
