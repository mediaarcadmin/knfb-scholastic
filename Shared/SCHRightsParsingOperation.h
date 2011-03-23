//
//  SCHRightsParsingOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 16/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHRightsParsingOperation : NSOperation  <NSXMLParserDelegate> {

}

@property (nonatomic, assign) NSString *isbn;

@end
