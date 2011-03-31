//
//  SCHFlowEucBook.h
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNFBFlowEucBook.h"

@interface SCHFlowEucBook : KNFBFlowEucBook {
    NSString *isbn;
}

@property (nonatomic, readonly) NSString *isbn;

@end
