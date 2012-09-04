#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class LibreAccessActivityLogSvc_ItemsCount;
@class LibreAccessActivityLogSvc_StatusHolder;
@class LibreAccessActivityLogSvc_SaveDump;
@class LibreAccessActivityLogSvc_SaveDumpItemsList;
@class LibreAccessActivityLogSvc_SaveDumpItem;
@class LibreAccessActivityLogSvc_SaveDumpResponse;
@class LibreAccessActivityLogSvc_ListDump;
@class LibreAccessActivityLogSvc_ListDumpResponse;
@class LibreAccessActivityLogSvc_DumpList;
@class LibreAccessActivityLogSvc_DumpItem;
@class LibreAccessActivityLogSvc_SaveActivityLog;
@class LibreAccessActivityLogSvc_LogsList;
@class LibreAccessActivityLogSvc_LogItem;
@class LibreAccessActivityLogSvc_SaveActivityLogResponse;
@class LibreAccessActivityLogSvc_SavedIdsList;
@class LibreAccessActivityLogSvc_SavedItem;
@class LibreAccessActivityLogSvc_ListActivityLog;
@class LibreAccessActivityLogSvc_Filters;
@class LibreAccessActivityLogSvc_ListActivityLogResponse;
@class LibreAccessActivityLogSvc_ActivityLogFactList;
@class LibreAccessActivityLogSvc_ActivityMasterNameList;
@class LibreAccessActivityLogSvc_FilterItem;
@class LibreAccessActivityLogSvc_ActivityLogFactItem;
@class LibreAccessActivityLogSvc_ActivityLogDetailList;
@class LibreAccessActivityLogSvc_ActivityLogDetailItem;
@class LibreAccessActivityLogSvc_ListAvailableDumps;
@class LibreAccessActivityLogSvc_UserKeysList;
@class LibreAccessActivityLogSvc_ListAvailableDumpsResponse;
@class LibreAccessActivityLogSvc_DumpListAvailable;
@class LibreAccessActivityLogSvc_DumpItemAvailable;
typedef enum {
	LibreAccessActivityLogSvc_statuscodes_none = 0,
	LibreAccessActivityLogSvc_statuscodes_SUCCESS,
	LibreAccessActivityLogSvc_statuscodes_FAIL,
} LibreAccessActivityLogSvc_statuscodes;
LibreAccessActivityLogSvc_statuscodes LibreAccessActivityLogSvc_statuscodes_enumFromString(NSString *string);
NSString * LibreAccessActivityLogSvc_statuscodes_stringFromEnum(LibreAccessActivityLogSvc_statuscodes enumValue);
@interface LibreAccessActivityLogSvc_ItemsCount : NSObject <NSCoding> {
/* elements */
	NSNumber * Returned;
	NSNumber * Found;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ItemsCount *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * Returned;
@property (nonatomic, retain) NSNumber * Found;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_StatusHolder : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_statuscodes status;
	NSNumber * statuscode;
	NSString * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_StatusHolder *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, assign) LibreAccessActivityLogSvc_statuscodes status;
@property (nonatomic, retain) NSNumber * statuscode;
@property (nonatomic, retain) NSString * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveDumpItem : NSObject <NSCoding> {
/* elements */
	NSString * CDATA;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveDumpItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CDATA;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveDumpItemsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *saveDumpItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveDumpItemsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSaveDumpItem:(LibreAccessActivityLogSvc_SaveDumpItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * saveDumpItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveDump : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	LibreAccessActivityLogSvc_SaveDumpItemsList * dumpItemsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveDump *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) LibreAccessActivityLogSvc_SaveDumpItemsList * dumpItemsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveDumpResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_StatusHolder * statusmessage;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveDumpResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessActivityLogSvc_StatusHolder * statusmessage;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListDump : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSNumber * countLastDumpsToBeReturned;
	NSNumber * applicationId;
	NSString * deviceKey;
	NSString * userKey;
	NSDate * minTimestamp;
	NSDate * maxTimestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListDump *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSNumber * countLastDumpsToBeReturned;
@property (nonatomic, retain) NSNumber * applicationId;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSDate * minTimestamp;
@property (nonatomic, retain) NSDate * maxTimestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_DumpItem : NSObject <NSCoding> {
/* elements */
	NSString * userKey;
	NSString * deviceKey;
	NSString * CDATA;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_DumpItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSString * CDATA;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_DumpList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dumpItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_DumpList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDumpItem:(LibreAccessActivityLogSvc_DumpItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dumpItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListDumpResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_StatusHolder * statusmessage;
	LibreAccessActivityLogSvc_DumpList * dumpList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListDumpResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessActivityLogSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessActivityLogSvc_DumpList * dumpList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_LogItem : NSObject <NSCoding> {
/* elements */
	NSString * definitionName;
	NSString * value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_LogItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * definitionName;
@property (nonatomic, retain) NSString * value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_LogsList : NSObject <NSCoding> {
/* elements */
	NSString * activityName;
	NSString * correlationID;
	NSMutableArray *logItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_LogsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * activityName;
@property (nonatomic, retain) NSString * correlationID;
- (void)addLogItem:(LibreAccessActivityLogSvc_LogItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * logItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveActivityLog : NSObject <NSCoding> {
/* elements */
	NSString * authToken;
	NSString * userKey;
	NSMutableArray *logsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveActivityLog *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * userKey;
- (void)addLogsList:(LibreAccessActivityLogSvc_LogsList *)toAdd;
@property (nonatomic, readonly) NSMutableArray * logsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SavedItem : NSObject <NSCoding> {
/* elements */
	NSString * correlationID;
	NSNumber * activityFactID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SavedItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * correlationID;
@property (nonatomic, retain) NSNumber * activityFactID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SavedIdsList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *savedItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SavedIdsList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addSavedItem:(LibreAccessActivityLogSvc_SavedItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * savedItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_SaveActivityLogResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_StatusHolder * statusmessage;
	LibreAccessActivityLogSvc_SavedIdsList * savedIdsList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_SaveActivityLogResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessActivityLogSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessActivityLogSvc_SavedIdsList * savedIdsList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_FilterItem : NSObject <NSCoding> {
/* elements */
	NSString * definitionName;
	NSString * activityLogValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_FilterItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * definitionName;
@property (nonatomic, retain) NSString * activityLogValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_Filters : NSObject <NSCoding> {
/* elements */
	NSMutableArray *filter;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_Filters *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addFilter:(LibreAccessActivityLogSvc_FilterItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * filter;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListActivityLog : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	NSString * activityMasterName;
	NSNumber * itemsCountToBeReturned;
	NSString * userKey;
	NSDate * minTimestamp;
	NSDate * maxTimestamp;
	LibreAccessActivityLogSvc_Filters * filters;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListActivityLog *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) NSString * activityMasterName;
@property (nonatomic, retain) NSNumber * itemsCountToBeReturned;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSDate * minTimestamp;
@property (nonatomic, retain) NSDate * maxTimestamp;
@property (nonatomic, retain) LibreAccessActivityLogSvc_Filters * filters;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ActivityLogDetailItem : NSObject <NSCoding> {
/* elements */
	NSNumber * activityLogDefinitionID;
	NSString * activityLogDefinitionName;
	NSString * activityLogDefinitionDesc;
	NSString * value;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ActivityLogDetailItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * activityLogDefinitionID;
@property (nonatomic, retain) NSString * activityLogDefinitionName;
@property (nonatomic, retain) NSString * activityLogDefinitionDesc;
@property (nonatomic, retain) NSString * value;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ActivityLogDetailList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *activityLogDetailItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ActivityLogDetailList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addActivityLogDetailItem:(LibreAccessActivityLogSvc_ActivityLogDetailItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * activityLogDetailItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ActivityLogFactItem : NSObject <NSCoding> {
/* elements */
	NSNumber * activityLogFactID;
	NSString * activityName;
	NSString * userKey;
	LibreAccessActivityLogSvc_ActivityLogDetailList * activityLogDetailList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ActivityLogFactItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSNumber * activityLogFactID;
@property (nonatomic, retain) NSString * activityName;
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) LibreAccessActivityLogSvc_ActivityLogDetailList * activityLogDetailList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ActivityLogFactList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *activityLogFactItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ActivityLogFactList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addActivityLogFactItem:(LibreAccessActivityLogSvc_ActivityLogFactItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * activityLogFactItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListActivityLogResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_StatusHolder * statusmessage;
	LibreAccessActivityLogSvc_ActivityLogFactList * activityLogFactList;
	LibreAccessActivityLogSvc_ItemsCount * ItemsCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListActivityLogResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessActivityLogSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessActivityLogSvc_ActivityLogFactList * activityLogFactList;
@property (nonatomic, retain) LibreAccessActivityLogSvc_ItemsCount * ItemsCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ActivityMasterNameList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *activityMasterName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ActivityMasterNameList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addActivityMasterName:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * activityMasterName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_UserKeysList : NSObject <NSCoding> {
/* elements */
	NSMutableArray *userKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_UserKeysList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addUserKey:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * userKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListAvailableDumps : NSObject <NSCoding> {
/* elements */
	NSString * CSRtoken;
	LibreAccessActivityLogSvc_UserKeysList * userKeysList;
	NSDate * minTimestamp;
	NSDate * maxTimestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListAvailableDumps *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * CSRtoken;
@property (nonatomic, retain) LibreAccessActivityLogSvc_UserKeysList * userKeysList;
@property (nonatomic, retain) NSDate * minTimestamp;
@property (nonatomic, retain) NSDate * maxTimestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_DumpItemAvailable : NSObject <NSCoding> {
/* elements */
	NSString * userKey;
	NSString * deviceKey;
	NSDate * timestamp;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_DumpItemAvailable *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * userKey;
@property (nonatomic, retain) NSString * deviceKey;
@property (nonatomic, retain) NSDate * timestamp;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_DumpListAvailable : NSObject <NSCoding> {
/* elements */
	NSMutableArray *dumpItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_DumpListAvailable *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addDumpItem:(LibreAccessActivityLogSvc_DumpItemAvailable *)toAdd;
@property (nonatomic, readonly) NSMutableArray * dumpItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface LibreAccessActivityLogSvc_ListAvailableDumpsResponse : NSObject <NSCoding> {
/* elements */
	LibreAccessActivityLogSvc_StatusHolder * statusmessage;
	LibreAccessActivityLogSvc_DumpListAvailable * dumpItems;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (LibreAccessActivityLogSvc_ListAvailableDumpsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) LibreAccessActivityLogSvc_StatusHolder * statusmessage;
@property (nonatomic, retain) LibreAccessActivityLogSvc_DumpListAvailable * dumpItems;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "LibreAccessActivityLogSvc.h"
@class LibreAccessActivityLogOldSoap11Binding;
@interface LibreAccessActivityLogSvc : NSObject {
	
}
+ (LibreAccessActivityLogOldSoap11Binding *)LibreAccessActivityLogOldSoap11Binding;
@end
@class LibreAccessActivityLogOldSoap11BindingResponse;
@class LibreAccessActivityLogOldSoap11BindingOperation;
@protocol LibreAccessActivityLogOldSoap11BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation completedWithResponse:(LibreAccessActivityLogOldSoap11BindingResponse *)response;
@end
@interface LibreAccessActivityLogOldSoap11Binding : NSObject <LibreAccessActivityLogOldSoap11BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval timeout;
	NSMutableArray *cookies;
	NSMutableDictionary *customHeaders;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
    NSMutableArray *operationPointers;
}
@property (nonatomic, copy) NSURL *address;
@property (nonatomic) BOOL logXMLInOut;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSMutableDictionary *customHeaders;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
@property (nonatomic, retain) NSMutableArray *operationPointers;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (LibreAccessActivityLogOldSoap11BindingResponse *)SaveActivityLogUsingParameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters ;
- (void)SaveActivityLogAsyncUsingParameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessActivityLogOldSoap11BindingResponse *)SaveDumpUsingParameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters ;
- (void)SaveDumpAsyncUsingParameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListActivityLogUsingParameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters ;
- (void)ListActivityLogAsyncUsingParameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListDumpUsingParameters:(LibreAccessActivityLogSvc_ListDump *)aParameters ;
- (void)ListDumpAsyncUsingParameters:(LibreAccessActivityLogSvc_ListDump *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate;
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListAvailableDumpsUsingParameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters ;
- (void)ListAvailableDumpsAsyncUsingParameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation;
- (void)removePointerForOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface LibreAccessActivityLogOldSoap11BindingOperation : NSOperation {
	LibreAccessActivityLogOldSoap11Binding *binding;
	LibreAccessActivityLogOldSoap11BindingResponse *response;
	id<LibreAccessActivityLogOldSoap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) LibreAccessActivityLogOldSoap11Binding *binding;
@property (nonatomic, readonly) LibreAccessActivityLogOldSoap11BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessActivityLogOldSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface LibreAccessActivityLogOldSoap11Binding_SaveActivityLog : LibreAccessActivityLogOldSoap11BindingOperation {
	LibreAccessActivityLogSvc_SaveActivityLog * parameters;
}
@property (nonatomic, retain) LibreAccessActivityLogSvc_SaveActivityLog * parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters
;
@end
@interface LibreAccessActivityLogOldSoap11Binding_SaveDump : LibreAccessActivityLogOldSoap11BindingOperation {
	LibreAccessActivityLogSvc_SaveDump * parameters;
}
@property (nonatomic, retain) LibreAccessActivityLogSvc_SaveDump * parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters
;
@end
@interface LibreAccessActivityLogOldSoap11Binding_ListActivityLog : LibreAccessActivityLogOldSoap11BindingOperation {
	LibreAccessActivityLogSvc_ListActivityLog * parameters;
}
@property (nonatomic, retain) LibreAccessActivityLogSvc_ListActivityLog * parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters
;
@end
@interface LibreAccessActivityLogOldSoap11Binding_ListDump : LibreAccessActivityLogOldSoap11BindingOperation {
	LibreAccessActivityLogSvc_ListDump * parameters;
}
@property (nonatomic, retain) LibreAccessActivityLogSvc_ListDump * parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessActivityLogSvc_ListDump *)aParameters
;
@end
@interface LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps : LibreAccessActivityLogOldSoap11BindingOperation {
	LibreAccessActivityLogSvc_ListAvailableDumps * parameters;
}
@property (nonatomic, retain) LibreAccessActivityLogSvc_ListAvailableDumps * parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
	parameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters
;
@end
@interface LibreAccessActivityLogOldSoap11Binding_envelope : NSObject {
}
+ (LibreAccessActivityLogOldSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface LibreAccessActivityLogOldSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
