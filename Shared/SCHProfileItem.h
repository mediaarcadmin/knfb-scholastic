//
//  SCHProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SCHSyncEntity+Extensions.h"


@interface SCHProfileItem :  SCHSyncEntity  
{
}

@property (nonatomic, retain) NSNumber * StoryInteractionEnabled;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSDate * LastPasswordModified;
@property (nonatomic, retain) NSString * Password;
@property (nonatomic, retain) NSDate * Birthday;
@property (nonatomic, retain) NSString * FirstName;
@property (nonatomic, retain) NSNumber * ProfilePasswordRequired;
@property (nonatomic, retain) NSNumber * Type;
@property (nonatomic, retain) NSString * ScreenName;
@property (nonatomic, retain) NSNumber * AutoAssignContentToProfiles;
@property (nonatomic, retain) NSDate * LastScreenNameModified;
@property (nonatomic, retain) NSString * UserKey;
@property (nonatomic, retain) NSNumber * BookshelfStyle;
@property (nonatomic, retain) NSString * LastName;

@end



