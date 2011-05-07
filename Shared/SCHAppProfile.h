//
//  SCHAppProfile.h
//  Scholastic
//
//  Created by John S. Eddie on 06/05/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHProfileItem;

static NSString * const kSCHAppProfile = @"SCHAppProfile";

@interface SCHAppProfile : NSManagedObject 
{
}

@property (nonatomic, retain) NSNumber * SelectedTheme;
@property (nonatomic, retain) SCHProfileItem * ProfileItem;

@end
