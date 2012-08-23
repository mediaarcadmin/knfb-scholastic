//
//  SCHBSBReplacedElementPlaceholder
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <libEucalyptus/EucCSSReplacedElement.h>

@interface SCHBSBReplacedElementPlaceholder : NSObject <EucCSSReplacedElement>

@property (nonatomic, assign) CGFloat pointSize;

- (id)initWithPointSize:(CGFloat)point;

@end
