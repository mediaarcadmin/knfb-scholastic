#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class GetUserInfoSvc_Exception;
@class GetUserInfoSvc_processRemote;
@class GetUserInfoSvc_processRemoteResponse;
@class GetUserInfoSvc_SchWSException;
@class GetUserInfoSvc_checkIfValidPropertyRequested;
#import "ax25.h"
@interface GetUserInfoSvc_processRemote : NSObject <NSCoding> {
/* elements */
	NSString * SPSWSXML;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (GetUserInfoSvc_processRemote *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * SPSWSXML;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface GetUserInfoSvc_processRemoteResponse : NSObject <NSCoding> {
/* elements */
	NSString * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (GetUserInfoSvc_processRemoteResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface GetUserInfoSvc_SchWSException : NSObject <NSCoding> {
/* elements */
	ax25_SchWSException * SchWSException;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (GetUserInfoSvc_SchWSException *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) ax25_SchWSException * SchWSException;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface GetUserInfoSvc_checkIfValidPropertyRequested : NSObject <NSCoding> {
/* elements */
	NSString * name;
	NSString * clientID;
	NSString * serviceName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (GetUserInfoSvc_checkIfValidPropertyRequested *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * clientID;
@property (nonatomic, retain) NSString * serviceName;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "GetUserInfoSvc.h"
#import "ax25.h"
@class GetUserInfoSoap11Binding;
@interface GetUserInfoSvc : NSObject {
	
}
+ (GetUserInfoSoap11Binding *)GetUserInfoSoap11Binding;
@end
@class GetUserInfoSoap11BindingResponse;
@class GetUserInfoSoap11BindingOperation;
@protocol GetUserInfoSoap11BindingResponseDelegate <NSObject>
- (void) operation:(GetUserInfoSoap11BindingOperation *)operation completedWithResponse:(GetUserInfoSoap11BindingResponse *)response;
@end
@interface GetUserInfoSoap11Binding : NSObject <GetUserInfoSoap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(GetUserInfoSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (GetUserInfoSoap11BindingResponse *)checkIfValidPropertyRequestedUsingParameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters ;
- (void)checkIfValidPropertyRequestedAsyncUsingParameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters  delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate;
- (GetUserInfoSoap11BindingResponse *)processRemoteUsingParameters:(GetUserInfoSvc_processRemote *)aParameters ;
- (void)processRemoteAsyncUsingParameters:(GetUserInfoSvc_processRemote *)aParameters  delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(GetUserInfoSoap11BindingOperation *)operation;
- (void)removePointerForOperation:(GetUserInfoSoap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface GetUserInfoSoap11BindingOperation : NSOperation {
	GetUserInfoSoap11Binding *binding;
	GetUserInfoSoap11BindingResponse *response;
	id<GetUserInfoSoap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) GetUserInfoSoap11Binding *binding;
@property (nonatomic, readonly) GetUserInfoSoap11BindingResponse *response;
@property (nonatomic, assign) id<GetUserInfoSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface GetUserInfoSoap11Binding_checkIfValidPropertyRequested : GetUserInfoSoap11BindingOperation {
	GetUserInfoSvc_checkIfValidPropertyRequested * parameters;
}
@property (nonatomic, retain) GetUserInfoSvc_checkIfValidPropertyRequested * parameters;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)aDelegate
	parameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters
;
@end
@interface GetUserInfoSoap11Binding_processRemote : GetUserInfoSoap11BindingOperation {
	GetUserInfoSvc_processRemote * parameters;
}
@property (nonatomic, retain) GetUserInfoSvc_processRemote * parameters;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)aDelegate
	parameters:(GetUserInfoSvc_processRemote *)aParameters
;
@end
@interface GetUserInfoSoap11Binding_envelope : NSObject {
}
+ (GetUserInfoSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface GetUserInfoSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
