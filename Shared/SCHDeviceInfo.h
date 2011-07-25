//
//  SCHDeviceInfo.h
//  Scholastic
//
//  Created by John S. Eddie on 23/02/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHDeviceInfo;

@interface SCHDeviceInfo :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * Active;
@property (nonatomic, retain) NSNumber * DeregistrationConfirmed;
@property (nonatomic, retain) NSDate * LastModified;
@property (nonatomic, retain) NSString * DeviceKey;
@property (nonatomic, retain) NSNumber * DeviceId;
@property (nonatomic, retain) NSNumber * AutoloadContent;
@property (nonatomic, retain) NSDate * BadLoginDatetimeUTC;
@property (nonatomic, retain) NSString * RemoveReason;
@property (nonatomic, retain) NSDate * LastActivated;
@property (nonatomic, retain) NSNumber * BadLoginAttempts;
@property (nonatomic, retain) NSString * DeviceNickname;
@property (nonatomic, retain) NSString * DevicePlatform;

@end



