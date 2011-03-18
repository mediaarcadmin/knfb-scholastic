//
//  SCHAppBookOrder.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHProfileItem;

@interface SCHAppBookOrder : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Order;
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) SCHProfileItem * ProfileItem;

@end
