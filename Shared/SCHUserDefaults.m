// 
//  SCHUserDefaults.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHUserDefaults.h"

// Constants
NSString * const kSCHUserDefaultsPerformedFirstSyncUpToBooks = @"PerformedFirstSyncUpToBooks";
NSString * const kSCHUserDefaultsWelcomeViewShowCount = @"SCHUserDefaultsWelcomeViewShowCount";
// This matches the corresponding string in Blio, so as to avoid
// having two different versions of the PlayReady lib.
NSString * const kSCHUserDefaultsDeviceID = @"lastDevice";

NSString * const kSCHAuthenticationManagerUserKey = @"AuthenticationManager.UserKey";   // AKA spsID
NSString * const kSCHAuthenticationManagerDeviceKey = @"AuthenticationManager.DeviceKey";
NSString * const kSCHAuthenticationManagerUsername = @"AuthenticationManager.Username";
