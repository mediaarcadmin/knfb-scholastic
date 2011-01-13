#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class AuthenticateSvc_processRemote;
@class AuthenticateSvc_processRemoteResponse;
@interface AuthenticateSvc_processRemote : NSObject {
	
/* elements */
	NSString * SPSWSXML;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (AuthenticateSvc_processRemote *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * SPSWSXML;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface AuthenticateSvc_processRemoteResponse : NSObject {
	
/* elements */
	NSString * return_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (AuthenticateSvc_processRemoteResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "AuthenticateSvc.h"
@class AuthenticateSoap11Binding;
@class AuthenticateSoap12Binding;
@interface AuthenticateSvc : NSObject {
	
}
+ (AuthenticateSoap11Binding *)AuthenticateSoap11Binding;
+ (AuthenticateSoap12Binding *)AuthenticateSoap12Binding;
@end
@class AuthenticateSoap11BindingResponse;
@class AuthenticateSoap11BindingOperation;
@protocol AuthenticateSoap11BindingResponseDelegate <NSObject>
- (void) operation:(AuthenticateSoap11BindingOperation *)operation completedWithResponse:(AuthenticateSoap11BindingResponse *)response;
@end
@interface AuthenticateSoap11Binding : NSObject <AuthenticateSoap11BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(AuthenticateSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (AuthenticateSoap11BindingResponse *)processRemoteUsingParameters:(AuthenticateSvc_processRemote *)aParameters ;
- (void)processRemoteAsyncUsingParameters:(AuthenticateSvc_processRemote *)aParameters  delegate:(id<AuthenticateSoap11BindingResponseDelegate>)responseDelegate;
@end
@interface AuthenticateSoap11BindingOperation : NSOperation {
	AuthenticateSoap11Binding *binding;
	AuthenticateSoap11BindingResponse *response;
	id<AuthenticateSoap11BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) AuthenticateSoap11Binding *binding;
@property (readonly) AuthenticateSoap11BindingResponse *response;
@property (nonatomic, assign) id<AuthenticateSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)aDelegate;
@end
@interface AuthenticateSoap11Binding_processRemote : AuthenticateSoap11BindingOperation {
	AuthenticateSvc_processRemote * parameters;
}
@property (retain) AuthenticateSvc_processRemote * parameters;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)aDelegate
	parameters:(AuthenticateSvc_processRemote *)aParameters
;
@end
@interface AuthenticateSoap11Binding_envelope : NSObject {
}
+ (AuthenticateSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface AuthenticateSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
@class AuthenticateSoap12BindingResponse;
@class AuthenticateSoap12BindingOperation;
@protocol AuthenticateSoap12BindingResponseDelegate <NSObject>
- (void) operation:(AuthenticateSoap12BindingOperation *)operation completedWithResponse:(AuthenticateSoap12BindingResponse *)response;
@end
@interface AuthenticateSoap12Binding : NSObject <AuthenticateSoap12BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(AuthenticateSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (AuthenticateSoap12BindingResponse *)processRemoteUsingParameters:(AuthenticateSvc_processRemote *)aParameters ;
- (void)processRemoteAsyncUsingParameters:(AuthenticateSvc_processRemote *)aParameters  delegate:(id<AuthenticateSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface AuthenticateSoap12BindingOperation : NSOperation {
	AuthenticateSoap12Binding *binding;
	AuthenticateSoap12BindingResponse *response;
	id<AuthenticateSoap12BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) AuthenticateSoap12Binding *binding;
@property (readonly) AuthenticateSoap12BindingResponse *response;
@property (nonatomic, assign) id<AuthenticateSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(AuthenticateSoap12Binding *)aBinding delegate:(id<AuthenticateSoap12BindingResponseDelegate>)aDelegate;
@end
@interface AuthenticateSoap12Binding_processRemote : AuthenticateSoap12BindingOperation {
	AuthenticateSvc_processRemote * parameters;
}
@property (retain) AuthenticateSvc_processRemote * parameters;
- (id)initWithBinding:(AuthenticateSoap12Binding *)aBinding delegate:(id<AuthenticateSoap12BindingResponseDelegate>)aDelegate
	parameters:(AuthenticateSvc_processRemote *)aParameters
;
@end
@interface AuthenticateSoap12Binding_envelope : NSObject {
}
+ (AuthenticateSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface AuthenticateSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
