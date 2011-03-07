//
//  SCHBookshelfSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"

static NSString * const kSCHBookshelfSyncComponentComplete = @"SCHBookshelfSyncComponentComplete";

@interface SCHBookshelfSyncComponent : SCHSyncComponent
{

}

@property (nonatomic, assign) BOOL useIndividualRequests;

@end
