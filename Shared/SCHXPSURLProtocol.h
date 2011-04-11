//
//  SCHXPSURLProtocol.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHXPSURLProtocol : NSURLProtocol {
    
}

+ (NSString *)xpsProtocolScheme;
+ (void)registerXPSProtocol;

@end
