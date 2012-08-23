//
//  SCHBSBReplacedDropdownElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 20/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementPlaceholder.h"

@interface SCHBSBReplacedDropdownElement : SCHBSBReplacedElementPlaceholder

- (id)initWithPointSize:(CGFloat)point keys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)binding;

@end
