//
//  SCHAnnotationSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHSyncComponent.h"


@interface SCHAnnotationSyncComponent : SCHSyncComponent 
{

}

@property (retain, nonatomic) NSNumber *profileID;
@property (retain, nonatomic) NSArray *books;

@end
