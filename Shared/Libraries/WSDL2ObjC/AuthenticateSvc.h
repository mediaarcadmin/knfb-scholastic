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
@class AuthenticateSoap11Binding;
@interface AuthenticateSvc : NSObject {
	
}
+ (AuthenticateSoap11Binding *)AuthenticateSoap11Binding;
@end
@class AuthenticateSoap11BindingResponse;
@class AuthenticateSoap11BindingOperation;
@protocol AuthenticateSoap11BindingResponseDelegate <NSObject>
- (void) operation:(AuthenticateSoap11BindingOperation *)operation completedWithResponse:(AuthenticateSoap11BindingResponse *)response;
@end
@interface AuthenticateSoap11Binding : NSObject <AuthenticateSoap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(AuthenticateSoap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
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
@property (nonatomic, retain) AuthenticateSoap11Binding *binding;
@property (nonatomic, readonly) AuthenticateSoap11BindingResponse *response;
@property (nonatomic, assign) id<AuthenticateSoap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)aDelegate;
@end
@interface AuthenticateSoap11Binding_processRemote : AuthenticateSoap11BindingOperation {
	AuthenticateSvc_processRemote * parameters;
}
@property (nonatomic, retain) AuthenticateSvc_processRemote * parameters;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)aDelegate
	parameters:(AuthenticateSvc_processRemote *)aParameters
;
@end
@interface AuthenticateSoap11Binding_envelope : NSObject {
}
+ (AuthenticateSoap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface AuthenticateSoap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
