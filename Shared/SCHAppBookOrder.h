//
//  SCHAppBookOrder.h
//  Scholastic
//
//  Created by John S. Eddie on 14/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SCHAppBookOrder : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * Order;
@property (nonatomic, retain) NSNumber * ProfileID;
@property (nonatomic, retain) NSString * ISBN;

@end
