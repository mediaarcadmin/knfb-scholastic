#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class tns1_StatusHolder2;
@class tns1_LogsList;
@class tns1_LogItem;
@class tns1_SavedIdsList;
@class tns1_SavedItem;
@class tns1_SaveActivityLogRequest;
@class tns1_SaveActivityLogResponse;
typedef enum {
	tns1_StatusCodes_none = 0,
	tns1_StatusCodes_SUCCESS,
	tns1_StatusCodes_FAIL,
} tns1_StatusCodes;
tns1_StatusCodes tns1_StatusCodes_enumFromString(NSString *string);
NSString * tns1_StatusCodes_stringFromEnum(tns1_StatusCodes enumValue);
@interface tns1_StatusHolder2 : NSObject <NSCoding> {
/* elements */
	tns1_StatusCodes status;
	NSNumber * statusCode;
	NSString * statusMessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_StatusHolder2 *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) tns1_StatusCodes status;
@property (nonatomic, retain) NSNumber * statusCode;
@property (nonatomic, retain) NSString * statusMessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LogItem : NSObject <NSCoding> {
/* elements */
	NSString * definitionName;
	NSString * value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LogItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * definitionName;
@property (nonatomic, retain) NSString * value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_LogsList : NSObject <NSCoding> {
/* elements */
	NSString * activityName;
	NSString * correlationId;
	NSMutableArray *logItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_LogsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * activityName;
@property (nonatomic, retain) NSString * correlationId;
- (void)addLogItem:(tns1_LogItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * logItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SavedItem : NSObject <NSCoding> {
/* elements */
	NSString * correlationId;
	NSNumber * activityFactId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SavedItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * correlationId;
@property (nonatomic, retain) NSNumber * activityFactId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SavedIdsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *savedItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SavedIdsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSavedItem:(tns1_SavedItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * savedItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveActivityLogRequest : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSString * userKey;
	NSDate * creationDate;
	NSMutableArray *logsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveActivityLogRequest *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSDate * creationDate;
- (void)addLogsList:(tns1_LogsList *)toAdd;
@property (nonatomic, readonly) NSMutableArray * logsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface tns1_SaveActivityLogResponse : NSObject <NSCoding> {
/* elements */
	tns1_StatusHolder2 * statusMessage;
	tns1_SavedIdsList * savedIdsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (tns1_SaveActivityLogResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) tns1_StatusHolder2 * statusMessage;
@property (nonatomic, retain) tns1_SavedIdsList * savedIdsList;
/* attributes */
- (NSDictionary *)attributes;
@end
