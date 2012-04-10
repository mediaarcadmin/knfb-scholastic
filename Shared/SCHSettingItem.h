//
//  SCHSettingItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHSettingItem;

extern NSString * const kSCHSettingItemSTORE_READ_STAT;
extern NSString * const kSCHSettingItemDISABLE_AUTOASSIGN;
extern NSString * const kSCHSettingItemRECOMMENDATIONS_ON;

@interface SCHSettingItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * SettingValue;
@property (nonatomic, retain) NSString * settingName;

@end



