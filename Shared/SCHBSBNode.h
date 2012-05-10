//
//  SCHBSBNode.h
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHBSBNode : NSObject

@property (nonatomic, copy) NSString *nodeId;
@property (nonatomic, copy) NSString *uri;

- (void)clearDecisions;

@end
