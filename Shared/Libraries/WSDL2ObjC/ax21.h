#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class ax21_WishListProfileItem;
@class ax21_WishListStatus;
@class ax21_WishList;
@class ax21_WishListProfile;
@class ax21_WishListItem;
@class ax21_InitiatedByEnum;
@class ax21_WishListProfileStatus;
@class ax21_WishListError;
@class ax21_WishListItemStatus;
@interface ax21_InitiatedByEnum : NSObject <NSCoding> {
/* elements */
	NSString * value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_InitiatedByEnum *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListItem : NSObject <NSCoding> {
/* elements */
	NSString * author;
	ax21_InitiatedByEnum * initiatedBy;
	NSString * isbn;
	NSDate * timeStamp;
	NSString * title;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) ax21_InitiatedByEnum * initiatedBy;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListProfile : NSObject <NSCoding> {
/* elements */
	NSNumber * profileID;
	NSString * profileName;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListProfile *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * profileID;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListProfileItem : NSObject <NSCoding> {
/* elements */
	NSMutableArray *itemList;
	ax21_WishListProfile * profile;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListProfileItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addItemList:(ax21_WishListItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * itemList;
@property (nonatomic, retain) ax21_WishListProfile * profile;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListError : NSObject <NSCoding> {
/* elements */
	NSNumber * errorCode;
	NSString * errorMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListError *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * errorCode;
@property (nonatomic, retain) NSString * errorMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListItemStatus : NSObject <NSCoding> {
/* elements */
	NSString * isbn;
	ax21_WishListError * itemError;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListItemStatus *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) ax21_WishListError * itemError;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListProfileStatus : NSObject <NSCoding> {
/* elements */
	NSMutableArray *itemStatusList;
	ax21_WishListError * profileError;
	NSNumber * profileID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListProfileStatus *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addItemStatusList:(ax21_WishListItemStatus *)toAdd;
@property (nonatomic, readonly) NSMutableArray * itemStatusList;
@property (nonatomic, retain) ax21_WishListError * profileError;
@property (nonatomic, retain) NSNumber * profileID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishListStatus : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileStatusList;
	NSNumber * spsID;
	ax21_WishListError * wishListError;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishListStatus *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileStatusList:(ax21_WishListProfileStatus *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileStatusList;
@property (nonatomic, retain) NSNumber * spsID;
@property (nonatomic, retain) ax21_WishListError * wishListError;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface ax21_WishList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *profileItemList;
	NSNumber * spsID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (ax21_WishList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileItemList;
@property (nonatomic, retain) NSNumber * spsID;
/* attributes */
- (NSDictionary *)attributes;
@end
