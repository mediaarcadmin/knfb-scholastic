//
//  SCHBSBReplacedDropdownElement.h
//  Scholastic
//
//  Created by Matt Farrugia on 20/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElement.h"

@interface SCHBSBReplacedDropdownElement : SCHBSBReplacedElement

- (id)initWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)dropdownBinding value:(NSString *)aValue;

@property (nonatomic, assign) BOOL useWebview;

@end
