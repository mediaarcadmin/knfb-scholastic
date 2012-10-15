#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "LibreAccessActivityLogSvc.h"
#import "LibreAccessActivityLogSvc_tns1.h"
@class LibreAccessActivityLogV2Soap11Binding;
@interface LibreAccessActivityLogSvc : NSObject {
	
}
+ (LibreAccessActivityLogV2Soap11Binding *)LibreAccessActivityLogV2Soap11Binding;
@end
@class LibreAccessActivityLogV2Soap11BindingResponse;
@class LibreAccessActivityLogV2Soap11BindingOperation;
@protocol LibreAccessActivityLogV2Soap11BindingResponseDelegate <NSObject>
- (void) operation:(LibreAccessActivityLogV2Soap11BindingOperation *)operation completedWithResponse:(LibreAccessActivityLogV2Soap11BindingResponse *)response;
@end
@interface LibreAccessActivityLogV2Soap11Binding : NSObject <LibreAccessActivityLogV2Soap11BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(LibreAccessActivityLogV2Soap11BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (LibreAccessActivityLogV2Soap11BindingResponse *)SaveActivityLogUsingParameters:(tns1_SaveActivityLogRequest *)aParameters ;
- (void)SaveActivityLogAsyncUsingParameters:(tns1_SaveActivityLogRequest *)aParameters  delegate:(id<LibreAccessActivityLogV2Soap11BindingResponseDelegate>)responseDelegate;
- (void)addPointerForOperation:(LibreAccessActivityLogV2Soap11BindingOperation *)operation;
- (void)removePointerForOperation:(LibreAccessActivityLogV2Soap11BindingOperation *)operation;
- (void)clearBindingOperations;
@end
@interface LibreAccessActivityLogV2Soap11BindingOperation : NSOperation {
	LibreAccessActivityLogV2Soap11Binding *binding;
	LibreAccessActivityLogV2Soap11BindingResponse *response;
	id<LibreAccessActivityLogV2Soap11BindingResponseDelegate> delegate;
	NSDictionary *responseHeaders;	
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (nonatomic, retain) LibreAccessActivityLogV2Soap11Binding *binding;
@property (nonatomic, readonly) LibreAccessActivityLogV2Soap11BindingResponse *response;
@property (nonatomic, assign) id<LibreAccessActivityLogV2Soap11BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSDictionary *responseHeaders;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, assign) NSTimeInterval serverDateDelta;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(LibreAccessActivityLogV2Soap11Binding *)aBinding delegate:(id<LibreAccessActivityLogV2Soap11BindingResponseDelegate>)aDelegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)clear;
@end
@interface LibreAccessActivityLogV2Soap11Binding_SaveActivityLog : LibreAccessActivityLogV2Soap11BindingOperation {
	tns1_SaveActivityLogRequest * parameters;
}
@property (nonatomic, retain) tns1_SaveActivityLogRequest * parameters;
- (id)initWithBinding:(LibreAccessActivityLogV2Soap11Binding *)aBinding delegate:(id<LibreAccessActivityLogV2Soap11BindingResponseDelegate>)aDelegate
	parameters:(tns1_SaveActivityLogRequest *)aParameters
;
@end
@interface LibreAccessActivityLogV2Soap11Binding_envelope : NSObject {
}
+ (LibreAccessActivityLogV2Soap11Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface LibreAccessActivityLogV2Soap11BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
