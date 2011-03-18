//
//  SCHAppBook.h
//  Scholastic
//
//  Created by Gordon Christie on 18/03/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHContentMetadataItem;

@interface SCHAppBook :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * DRMVersion;
@property (nonatomic, retain) NSNumber * LayoutStartsOnLeftSide;
@property (nonatomic, retain) NSNumber * HasStoryInteractions;
@property (nonatomic, retain) NSNumber * State;
@property (nonatomic, retain) NSString * XPSCategory;
@property (nonatomic, retain) NSNumber * ReflowPermitted;
@property (nonatomic, retain) NSNumber * HasExtras;
@property (nonatomic, retain) NSString * XPSTitle;
@property (nonatomic, retain) NSNumber * HasAudio;
@property (nonatomic, retain) NSNumber * TTSPermitted;
@property (nonatomic, retain) NSString * XPSAuthor;
@property (nonatomic, retain) SCHContentMetadataItem * ContentMetadataItem;

@end



