//
//  SCHProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 12/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"


@interface SCHProfileItem :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSString * Lastname;
@property (nonatomic, retain) NSNumber * StoryInteractionEnabled;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSDate * LastPasswordModified;
@property (nonatomic, retain) NSDate * BirthDay;
@property (nonatomic, retain) NSString * Password;
@property (nonatomic, retain) NSString * Screenname;
@property (nonatomic, retain) NSString * Userkey;
@property (nonatomic, retain) NSNumber * ProfilePasswordRequired;
@property (nonatomic, retain) NSNumber * Type;
@property (nonatomic, retain) NSString * Firstname;
@property (nonatomic, retain) NSNumber * AutoAssignContentToProfiles;
@property (nonatomic, retain) NSDate * LastScreenNameModified;
@property (nonatomic, retain) NSNumber * BookshelfStyle;

@end



