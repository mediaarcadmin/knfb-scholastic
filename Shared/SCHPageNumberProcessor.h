//
//  SCHPageNumberProcessor.h
//  Scholastic
//
//  Created by John S. Eddie on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Constants
extern NSString * const kSCHPageNumberProcessorErrorDomain;
extern NSInteger const kSCHPageNumberProcessorFileError;
extern NSInteger const kSCHPageNumberProcessorDataError;

@interface SCHPageNumberProcessor : NSObject <NSXMLParserDelegate>
{    
}

- (NSDictionary *)pageNumbersFrom:(NSData *)pageData 
                   withPageIndexRange:(NSRange)pageIndexRange 
                       error:(NSError **)error;


@end
