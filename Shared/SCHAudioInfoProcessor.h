//
//  SCHAudioInfoProcessor.h
//  Scholastic
//
//  Created by John S. Eddie on 27/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHAudioInfoProcessor : NSObject <NSXMLParserDelegate>
{    
}

- (NSArray *)audioInfoFrom:(NSData *)audioData error:(NSError **)error;

@end
