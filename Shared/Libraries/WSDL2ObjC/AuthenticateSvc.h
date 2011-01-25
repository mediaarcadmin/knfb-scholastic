#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class AuthenticateSvc_processRemote;
@class AuthenticateSvc_processRemoteResponse;
@interface AuthenticateSvc_processRemote : NSObject <NSCoding> {
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
@property (nonatomic, retain) NSString * SPSWSXML;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface AuthenticateSvc_processRemoteResponse : NSObject <NSCoding> {
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
@property (nonatomic, retain) NSString * return_;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "AuthenticateSvc.h"
@class AuthenticateSoap12Binding;
@interface AuthenticateSvc : NSObject {
	
}
+ (AuthenticateSoap12Binding *)AuthenticateSoap12Binding;
@end
@class AuthenticateSoap12BindingResponse;
@class AuthenticateSoap12BindingOperation;
@protocol AuthenticateSoap12BindingResponseDelegate <NSObject>
- (void) operation:(AuthenticateSoap12BindingOperation *)operation completedWithResponse:(AuthenticateSoap12BindingResponse *)response;
@end
@interface AuthenticateSoap12Binding : NSObject <AuthenticateSoap12BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval timeout;
	NSMutableArray *cookies;
	NSMutableDictionary *customHeaders;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (nonatomic, copy) NSURL *address;
@property (nonatomic) BOOL logXMLInOut;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSMutableDictionary *customHeaders;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(AuthenticateSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
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
@property (nonatomic, retain) AuthenticateSoap12Binding *binding;
@property (nonatomic, readonly) AuthenticateSoap12BindingResponse *response;
@property (nonatomic, assign) id<AuthenticateSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(AuthenticateSoap12Binding *)aBinding delegate:(id<AuthenticateSoap12BindingResponseDelegate>)aDelegate;
@end
@interface AuthenticateSoap12Binding_processRemote : AuthenticateSoap12BindingOperation {
	AuthenticateSvc_processRemote * parameters;
}
@property (nonatomic, retain) AuthenticateSvc_processRemote * parameters;
- (id)initWithBinding:(AuthenticateSoap12Binding *)aBinding delegate:(id<AuthenticateSoap12BindingResponseDelegate>)aDelegate
	parameters:(AuthenticateSvc_processRemote *)aParameters
;
@end
@interface AuthenticateSoap12Binding_envelope : NSObject {
}
+ (AuthenticateSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface AuthenticateSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
