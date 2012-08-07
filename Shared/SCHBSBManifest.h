//
//  SCHBSBManifest.h
//  Scholastic
//
//  Created by Matt Farrugia on 10/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHBSBManifest : NSObject

- (id)initWithXMLData:(NSData *)data;

- (NSDictionary *)metadata;
- (NSArray *)nodes; // SCHBSBNode array;

@end