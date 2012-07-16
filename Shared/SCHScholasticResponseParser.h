//
//  SCHScholasticResponseParser.h
//  Scholastic
//
//  Created by John Eddie on 13/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHScholasticResponseParser : NSObject

- (NSDictionary *)parseXMLString:(NSString *)xmlString;

+ (NSError *)errorFromDictionary:(NSDictionary *)responseDictionary;

@end
