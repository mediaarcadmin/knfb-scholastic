#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class WishListServiceSvc_DeleteWishListItems;
@class WishListServiceSvc_DeleteWishListItemsResponse;
@class WishListServiceSvc_AddItemsToWishList;
@class WishListServiceSvc_AddItemsToWishListResponse;
@class WishListServiceSvc_GetWishListItems;
@class WishListServiceSvc_GetWishListItemsResponse;
@class WishListServiceSvc_DeleteWishList;
@class WishListServiceSvc_DeleteWishListResponse;
#import "ax21.h"
@interface WishListServiceSvc_DeleteWishListItems : NSObject <NSCoding> {
/* elements */
	NSString * clientID;
	NSString * token;
	NSString * spsIdParam;
	NSMutableArray *profileItemList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_DeleteWishListItems *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * spsIdParam;
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileItemList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_DeleteWishListItemsResponse : NSObject <NSCoding> {
/* elements */
	ax21_WishListStatus * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_DeleteWishListItemsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) ax21_WishListStatus * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_AddItemsToWishList : NSObject <NSCoding> {
/* elements */
	NSString * clientID;
	NSString * token;
	NSString * spsIdParam;
	NSMutableArray *profileItemList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_AddItemsToWishList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * spsIdParam;
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileItemList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_AddItemsToWishListResponse : NSObject <NSCoding> {
/* elements */
	ax21_WishListStatus * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_AddItemsToWishListResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) ax21_WishListStatus * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_GetWishListItems : NSObject <NSCoding> {
/* elements */
	NSString * clientID;
	NSString * token;
	NSString * spsIdParam;
	NSMutableArray *profileIdList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_GetWishListItems *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * spsIdParam;
- (void)addProfileIdList:(NSNumber *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileIdList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_GetWishListItemsResponse : NSObject <NSCoding> {
/* elements */
	ax21_WishList * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_GetWishListItemsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) ax21_WishList * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_DeleteWishList : NSObject <NSCoding> {
/* elements */
	NSString * clientID;
	NSString * token;
	NSString * spsIdParam;
	NSMutableArray *profileIdList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_DeleteWishList *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * spsIdParam;
- (void)addProfileIdList:(ax21_WishListProfile *)toAdd;
@property (nonatomic, readonly) NSMutableArray * profileIdList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WishListServiceSvc_DeleteWishListResponse : NSObject <NSCoding> {
/* elements */
	ax21_WishListStatus * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WishListServiceSvc_DeleteWishListResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) ax21_WishListStatus * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "WishListServiceSvc.h"
#import "ax21.h"
@class WishListServiceSoap11Binding;
@interface WishListServiceSvc : NSObject {
	
}
+ (WishListServiceSoap11Binding *)WishListServiceSoap11Binding;
@end
@class WishListServiceSoap11BindingResponse;
@class WishListServiceSoap11BindingOperation;
@protocol WishListServiceSoap11BindingResponseDelegate <NSObject>
- (void) operation:(WishListServiceSoap11BindingOperation *)operation completedWithResponse:(WishListServiceSoap11BindingResponse *)response;
@end
@interface WishListServiceSoap11Binding : NSObject <WishListServiceSoap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(WishListServiceSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (WishListServiceSoap11BindingResponse *)DeleteWishListUsingParameters:(WishListServiceSvc_DeleteWishList *)aParameters ;
- (void)DeleteWishListAsyncUsingParameters:(WishListServiceSvc_DeleteWishList *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate;
- (WishListServiceSoap11BindingResponse *)DeleteWishListItemsUsingParameters:(WishListServiceSvc_DeleteWishListItems *)aParameters ;
- (void)DeleteWishListItemsAsyncUsingParameters:(WishListServiceSvc_DeleteWishListItems *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate;
- (WishListServiceSoap11BindingResponse *)AddItemsToWishListUsingParameters:(WishListServiceSvc_AddItemsToWishList *)aParameters ;
- (void)AddItemsToWishListAsyncUsingParameters:(WishListServiceSvc_AddItemsToWishList *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate;
- (WishListServiceSoap11BindingResponse *)GetWishListItemsUsingParameters:(WishListServiceSvc_GetWishListItems *)aParameters ;
- (void)GetWishListItemsAsyncUsingParameters:(WishListServiceSvc_GetWishListItems *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(WishListServiceSoap11BindingOperation *)operation;
- (void)removePointerForOperation:(WishListServiceSoap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface WishListServiceSoap11BindingOperation : NSOperation {
	WishListServiceSoap11Binding *binding;
	WishListServiceSoap11BindingResponse *response;
	id<WishListServiceSoap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) WishListServiceSoap11Binding *binding;
@property (nonatomic, readonly) WishListServiceSoap11BindingResponse *response;
@property (nonatomic, assign) id<WishListServiceSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface WishListServiceSoap11Binding_DeleteWishList : WishListServiceSoap11BindingOperation {
	WishListServiceSvc_DeleteWishList * parameters;
}
@property (nonatomic, retain) WishListServiceSvc_DeleteWishList * parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(WishListServiceSvc_DeleteWishList *)aParameters
;
@end
@interface WishListServiceSoap11Binding_DeleteWishListItems : WishListServiceSoap11BindingOperation {
	WishListServiceSvc_DeleteWishListItems * parameters;
}
@property (nonatomic, retain) WishListServiceSvc_DeleteWishListItems * parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(WishListServiceSvc_DeleteWishListItems *)aParameters
;
@end
@interface WishListServiceSoap11Binding_AddItemsToWishList : WishListServiceSoap11BindingOperation {
	WishListServiceSvc_AddItemsToWishList * parameters;
}
@property (nonatomic, retain) WishListServiceSvc_AddItemsToWishList * parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(WishListServiceSvc_AddItemsToWishList *)aParameters
;
@end
@interface WishListServiceSoap11Binding_GetWishListItems : WishListServiceSoap11BindingOperation {
	WishListServiceSvc_GetWishListItems * parameters;
}
@property (nonatomic, retain) WishListServiceSvc_GetWishListItems * parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate
	parameters:(WishListServiceSvc_GetWishListItems *)aParameters
;
@end
@interface WishListServiceSoap11Binding_envelope : NSObject {
}
+ (WishListServiceSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface WishListServiceSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
