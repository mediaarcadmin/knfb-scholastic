//
//  SCHXPSCoverImageOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"

@interface SCHXPSCoverImageOperation : NSOperation {

}

@property (nonatomic, retain) SCHBookInfo *bookInfo;
@property (nonatomic, retain) NSString *localPath;

@end
