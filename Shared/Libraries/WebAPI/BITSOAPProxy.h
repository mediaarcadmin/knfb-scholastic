//
//  BITSOAPProxy.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITAPIProxy.h"


@class SOAPFault;


@interface BITSOAPProxy : BITAPIProxy {

}

@property (nonatomic, retain) NSDateFormatter *rfc822DateFormatter;

- (void)reportFault:(SOAPFault *)fault 
          forMethod:(NSString *)method 
        requestInfo:(NSDictionary *)requestInfo;
- (NSError *)confirmErrorDomain:(NSError *)error 
                  forDomainName:(NSString *)domainName;

- (id)fromObjectTranslate:(id)anObject;

@end
