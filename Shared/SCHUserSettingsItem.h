//
//  SCHUserSettingsItem.h
//  Scholastic
//
//  Created by John S. Eddie on 27/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface SCHUserSettingsItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * SettingValue;
@property (nonatomic, retain) NSNumber * SettingType;

@end



