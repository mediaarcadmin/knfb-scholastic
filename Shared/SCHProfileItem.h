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

// Constants
extern NSString * const kSCHProfileItem;

extern NSString * const kSCHProfileItemFetchAnnotationsForProfileBook;
extern NSString * const kSCHProfileItemPROFILE_ID;
extern NSString * const kSCHProfileItemCONTENT_IDENTIFIER;
extern NSString * const kSCHProfileItemDRM_QUALIFIER;

typedef enum {
    kSCHBookSortTypeTitle,
    kSCHBookSortTypeAuthor,
    kSCHBookSortTypeNewest,
    kSCHBookSortTypeLastRead,
    kSCHBookSortTypeUser
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
- (NSMutableArray *)bookIdentifiersAssignedToProfile;
- (NSMutableArray *)allBookIdentifiers;
- (SCHBookAnnotations *)annotationsForBook:(SCHBookIdentifier *)bookIdentifier;
- (void)newStatistics:(SCHBookStatistics *)bookStatistics forBook:(SCHBookIdentifier *)bookIdentifier;
- (void)saveBookOrder:(NSArray *)books;
- (void)clearBookOrder:(NSArray *)books;
- (NSString *)bookshelfName:(BOOL)shortName;
- (void)setRawPassword:(NSString *)value;
- (BOOL)hasPassword;
- (BOOL)validatePasswordWith:(NSString *)withPassword;
- (BOOL)storyInteractionsDisabled;

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
@property (nonatomic, assign) BOOL isNewBook;

@end
