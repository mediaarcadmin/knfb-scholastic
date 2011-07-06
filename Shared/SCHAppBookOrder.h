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

static NSString * const kSCHAppBookOrder = @"SCHAppBookOrder";

static NSString * const kSCHAppBookOrderOrder = @"Order";
static NSString * const kSCHAppBookOrderISBN = @"ISBN";
static NSString * const kSCHAppBookOrderDRMQualifier = @"DRMQualifier";

@interface SCHAppBookOrder : NSManagedObject {

}

@property (nonatomic, retain) NSNumber * Order;
@property (nonatomic, retain) NSString * ISBN;
@property (nonatomic, retain) NSNumber * DRMQualifier;
@property (nonatomic, retain) SCHProfileItem * ProfileItem;

@end
