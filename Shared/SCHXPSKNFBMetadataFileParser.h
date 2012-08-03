//
//  SCHXPSKNFBMetadataFileParser.h
//  Scholastic
//
//  Created by John Eddie on 16/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kSCHXPSKNFBMetadataFileParserAuthor;
extern NSString * const kSCHXPSKNFBMetadataFileParserTitle;
extern NSString * const kSCHXPSKNFBMetadataFileParserISBN;

@interface SCHXPSKNFBMetadataFileParser : NSObject

- (NSDictionary *)parseXMLData:(NSData *)xmlData;

@end
