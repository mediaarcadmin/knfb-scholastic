//
//  SCHBSBReplacedElementPlaceholder
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <libEucalyptus/EucCSSReplacedElement.h>
#import "SCHBSBReplacedElementDelegate.h"

@interface SCHBSBReplacedElement : NSObject <EucCSSReplacedElement>

@property (nonatomic, assign) CGFloat pointSize;
@property (nonatomic, assign) id <SCHBSBReplacedElementDelegate> delegate;
@property (nonatomic, copy) NSString *nodeId;

@end
