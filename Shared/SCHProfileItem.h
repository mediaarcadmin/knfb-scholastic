//
//  SCHProfileItem.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHSyncEntity.h"

@class SCHAppContentProfileItem;
@class SCHAppProfile;
@class SCHContentProfileItem;
@class SCHPrivateAnnotations;
@class SCHBookAnnotations;
@class SCHBookStatistics;
@class SCHContentMetadataItem;
@class SCHBookIdentifier;

static NSString * const kSCHProfileItem = @"SCHProfileItem";

static NSString * const kSCHProfileItemFetchAnnotationsForProfileBook = @"fetchAnnotationsForProfileBook";
static NSString * const kSCHProfileItemPROFILE_ID = @"PROFILE_ID";
static NSString * const kSCHProfileItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
static NSString * const kSCHProfileItemDRM_QUALIFIER = @"DRM_QUALIFIER";

typedef enum {
    kSCHBookSortTypeUser,
    kSCHBookSortTypeTitle,
    kSCHBookSortTypeAuthor,
    kSCHBookSortTypeNewest,
    kSCHBookSortTypeLastRead,
} SCHBookSortType;

@interface SCHProfileItem : SCHSyncEntity 
{
}

@property (nonatomic, retain) NSNumber * StoryInteractionEnabled;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSDate * LastPasswordModified;
@property (nonatomic, retain) NSString * Password;
@property (nonatomic, retain) NSDate * Birthday;
@property (nonatomic, retain) NSString * FirstName;
@property (nonatomic, retain) NSNumber * ProfilePasswordRequired;
@property (nonatomic, retain) NSString * ScreenName;
@property (nonatomic, retain) NSNumber * Type;
@property (nonatomic, retain) NSDate * LastScreenNameModified;
@property (nonatomic, retain) NSNumber * AutoAssignContentToProfiles;
@property (nonatomic, retain) NSString * UserKey;
@property (nonatomic, retain) NSNumber * BookshelfStyle;
@property (nonatomic, retain) NSString * LastName;
@property (nonatomic, retain) SCHAppProfile * AppProfile;
@property (nonatomic, retain) NSSet * AppContentProfileItem;

@property (nonatomic, readonly) NSSet *ContentProfileItem;
@property (nonatomic, readonly) NSUInteger age;

- (SCHAppContentProfileItem *)appContentProfileItemForBookIdentifier:(SCHBookIdentifier *)bookIdentifier;
- (NSMutableArray *)allBookIdentifiers;
- (SCHBookAnnotations *)annotationsForBook:(SCHBookIdentifier *)bookIdentifier;
- (void)newStatistics:(SCHBookStatistics *)bookStatistics forBook:(SCHBookIdentifier *)bookIdentifier;
- (void)saveBookOrder:(NSArray *)books;
- (NSString *)bookshelfName:(BOOL)shortName;
- (void)setRawPassword:(NSString *)value;
- (BOOL)hasPassword;
- (BOOL)validatePasswordWith:(NSString *)withPassword;

@end

@interface SCHProfileItem (CoreDataGeneratedAccessors)

- (void)addAppContentProfileItemObject:(SCHAppContentProfileItem *)value;
- (void)removeAppContentProfileItemObject:(SCHAppContentProfileItem *)value;
- (void)addAppContentProfileItem:(NSSet *)value;
- (void)removeAppContentProfileItem:(NSSet *)value;

@end


@interface SCHProfileItemSortObject : NSObject

@property (nonatomic, retain) SCHContentMetadataItem *item;
@property (nonatomic, retain) NSDate *date;

@end
