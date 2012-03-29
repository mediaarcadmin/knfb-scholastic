#import "AuthenticateSvc.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
@implementation AuthenticateSvc_processRemote
- (id)init
{
	if((self = [super init])) {
		SPSWSXML = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(SPSWSXML != nil) [SPSWSXML release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"AuthenticateSvc";
}
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix
{
	NSString *nodeName = nil;
	if(elNSPrefix != nil && [elNSPrefix length] > 0)
	{
		nodeName = [NSString stringWithFormat:@"%@:%@", elNSPrefix, elName];
	}
	else
	{
		nodeName = [NSString stringWithFormat:@"%@:%@", @"AuthenticateSvc", elName];
	}
	xmlNodePtr node = xmlNewDocNode(doc, NULL, [nodeName xmlString], NULL);
	
	[self addAttributesToNode:node];
	
	[self addElementsToNode:node];
	
	return node;
}
- (void)addAttributesToNode:(xmlNodePtr)node
{
	
}
- (void)addElementsToNode:(xmlNodePtr)node
{
	
	if(self.SPSWSXML != 0) {
		xmlAddChild(node, [self.SPSWSXML xmlNodeForDoc:node->doc elementName:@"SPSWSXML" elementNSPrefix:@"AuthenticateSvc"]);
	}
}
/* elements */
@synthesize SPSWSXML;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (AuthenticateSvc_processRemote *)deserializeNode:(xmlNodePtr)cur
{
	AuthenticateSvc_processRemote *newObject = [[AuthenticateSvc_processRemote new] autorelease];
	
	[newObject deserializeAttributesFromNode:cur];
	[newObject deserializeElementsFromNode:cur];
	
	return newObject;
}
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur
{
}
- (void)deserializeElementsFromNode:(xmlNodePtr)cur
{
	
	
	for( cur = cur->children ; cur != NULL ; cur = cur->next ) {
		if(cur->type == XML_ELEMENT_NODE) {
			xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
			NSString *elementString = nil;
			
			if(elementText != NULL) {
				elementString = [NSString stringWithCString:(char*)elementText encoding:NSUTF8StringEncoding];
				[elementString self]; // avoid compiler warning for unused var
				xmlFree(elementText);
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "SPSWSXML")) {
				BOOL nilProperty = NO;
                for(xmlAttrPtr attr = cur->properties; attr != NULL; attr = attr->next) {
                    if(xmlStrEqual(attr->name, (const xmlChar *) "nil") &&
                       attr->children &&
                       xmlStrEqual(attr->children->content, (const xmlChar *) "true"))
                        nilProperty = YES;
                        break;
                }
                if (nilProperty == NO) {
					Class elementClass = nil;
					xmlChar *instanceType = xmlGetNsProp(cur, (const xmlChar *) "type", (const xmlChar *) "http://www.w3.org/2001/XMLSchema-instance");
					if(instanceType == NULL) {
						elementClass = [NSString class];
					} else {
						NSString *elementTypeString = [NSString stringWithCString:(char*)instanceType encoding:NSUTF8StringEncoding];
					
						NSArray *elementTypeArray = [elementTypeString componentsSeparatedByString:@":"];
					
						NSString *elementClassString = nil;
						if([elementTypeArray count] > 1) {
							NSString *prefix = [elementTypeArray objectAtIndex:0];
							NSString *localName = [elementTypeArray objectAtIndex:1];
						
							xmlNsPtr elementNamespace = xmlSearchNs(cur->doc, cur, [prefix xmlString]);
						
							NSString *standardPrefix = [[USGlobals sharedInstance].wsdlStandardNamespaces objectForKey:[NSString stringWithCString:(char*)elementNamespace->href encoding:NSUTF8StringEncoding]];
						
							elementClassString = [NSString stringWithFormat:@"%@_%@", standardPrefix, localName];
						} else {
							elementClassString = [elementTypeString stringByReplacingOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0, [elementTypeString length])];
						}
					
						elementClass = NSClassFromString(elementClassString);
						xmlFree(instanceType);
					}
				
					id newChild = [elementClass deserializeNode:cur];
				
					self.SPSWSXML = newChild;
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
//	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
//		self = [(id)super initWithCoder:decoder];
//	} else {
		self = [super init];
//	}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id val = [decoder decodeObjectForKey:key];
		if (val == nil) { val = [NSNumber numberWithFloat:0.0]; }
		[self setValue:val forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
	return self;
}
- (void) encodeWithCoder:(NSCoder *)encoder {
	if ([super respondsToSelector:@selector(encodeWithCoder:)] && ![self isKindOfClass:[super class]]) {
		[super performSelector:@selector(encodeWithCoder:) withObject:encoder];
	}
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for (int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id val = [self valueForKey:key];
		[encoder encodeObject:val forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation AuthenticateSvc_processRemoteResponse
- (id)init
{
	if((self = [super init])) {
		return_ = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(return_ != nil) [return_ release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"AuthenticateSvc";
}
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix
{
	NSString *nodeName = nil;
	if(elNSPrefix != nil && [elNSPrefix length] > 0)
	{
		nodeName = [NSString stringWithFormat:@"%@:%@", elNSPrefix, elName];
	}
	else
	{
		nodeName = [NSString stringWithFormat:@"%@:%@", @"AuthenticateSvc", elName];
	}
	xmlNodePtr node = xmlNewDocNode(doc, NULL, [nodeName xmlString], NULL);
	
	[self addAttributesToNode:node];
	
	[self addElementsToNode:node];
	
	return node;
}
- (void)addAttributesToNode:(xmlNodePtr)node
{
	
}
- (void)addElementsToNode:(xmlNodePtr)node
{
	
	if(self.return_ != 0) {
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"AuthenticateSvc"]);
	}
}
/* elements */
@synthesize return_;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (AuthenticateSvc_processRemoteResponse *)deserializeNode:(xmlNodePtr)cur
{
	AuthenticateSvc_processRemoteResponse *newObject = [[AuthenticateSvc_processRemoteResponse new] autorelease];
	
	[newObject deserializeAttributesFromNode:cur];
	[newObject deserializeElementsFromNode:cur];
	
	return newObject;
}
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur
{
}
- (void)deserializeElementsFromNode:(xmlNodePtr)cur
{
	
	
	for( cur = cur->children ; cur != NULL ; cur = cur->next ) {
		if(cur->type == XML_ELEMENT_NODE) {
			xmlChar *elementText = xmlNodeListGetString(cur->doc, cur->children, 1);
			NSString *elementString = nil;
			
			if(elementText != NULL) {
				elementString = [NSString stringWithCString:(char*)elementText encoding:NSUTF8StringEncoding];
				[elementString self]; // avoid compiler warning for unused var
				xmlFree(elementText);
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "return")) {
				BOOL nilProperty = NO;
                for(xmlAttrPtr attr = cur->properties; attr != NULL; attr = attr->next) {
                    if(xmlStrEqual(attr->name, (const xmlChar *) "nil") &&
                       attr->children &&
                       xmlStrEqual(attr->children->content, (const xmlChar *) "true"))
                        nilProperty = YES;
                        break;
                }
                if (nilProperty == NO) {
					Class elementClass = nil;
					xmlChar *instanceType = xmlGetNsProp(cur, (const xmlChar *) "type", (const xmlChar *) "http://www.w3.org/2001/XMLSchema-instance");
					if(instanceType == NULL) {
						elementClass = [NSString class];
					} else {
						NSString *elementTypeString = [NSString stringWithCString:(char*)instanceType encoding:NSUTF8StringEncoding];
					
						NSArray *elementTypeArray = [elementTypeString componentsSeparatedByString:@":"];
					
						NSString *elementClassString = nil;
						if([elementTypeArray count] > 1) {
							NSString *prefix = [elementTypeArray objectAtIndex:0];
							NSString *localName = [elementTypeArray objectAtIndex:1];
						
							xmlNsPtr elementNamespace = xmlSearchNs(cur->doc, cur, [prefix xmlString]);
						
							NSString *standardPrefix = [[USGlobals sharedInstance].wsdlStandardNamespaces objectForKey:[NSString stringWithCString:(char*)elementNamespace->href encoding:NSUTF8StringEncoding]];
						
							elementClassString = [NSString stringWithFormat:@"%@_%@", standardPrefix, localName];
						} else {
							elementClassString = [elementTypeString stringByReplacingOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0, [elementTypeString length])];
						}
					
						elementClass = NSClassFromString(elementClassString);
						xmlFree(instanceType);
					}
				
					id newChild = [elementClass deserializeNode:cur];
				
					self.return_ = newChild;
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
//	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
//		self = [(id)super initWithCoder:decoder];
//	} else {
		self = [super init];
//	}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id val = [decoder decodeObjectForKey:key];
		if (val == nil) { val = [NSNumber numberWithFloat:0.0]; }
		[self setValue:val forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
	return self;
}
- (void) encodeWithCoder:(NSCoder *)encoder {
	if ([super respondsToSelector:@selector(encodeWithCoder:)] && ![self isKindOfClass:[super class]]) {
		[super performSelector:@selector(encodeWithCoder:) withObject:encoder];
	}
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for (int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id val = [self valueForKey:key];
		[encoder encodeObject:val forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation AuthenticateSvc
+ (void)initialize
{
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"xsd" forKey:@"http://www.w3.org/2001/XMLSchema"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"AuthenticateSvc" forKey:@"http://sps.schws.scholastic.com"];
}
+ (AuthenticateSoap11Binding *)AuthenticateSoap11Binding
{
	return [[[AuthenticateSoap11Binding alloc] initWithAddress:@"http://esvcsqa.scholastic.com/SchWS/services/SPS/Authenticate.AuthenticateHttpSoap11Endpoint/"] autorelease];
}
@end
@implementation AuthenticateSoap11Binding
@synthesize address;
@synthesize timeout;
@synthesize logXMLInOut;
@synthesize cookies;
@synthesize customHeaders;
@synthesize authUsername;
@synthesize authPassword;
@synthesize operationPointers;
+ (NSTimeInterval)defaultTimeout
{
	return 10;
}
- (id)init
{
	if((self = [super init])) {
		address = nil;
		cookies = nil;
		customHeaders = [NSMutableDictionary new];
		timeout = [[self class] defaultTimeout];
		logXMLInOut = NO;
		synchronousOperationComplete = NO;
        operationPointers = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (id)initWithAddress:(NSString *)anAddress
{
	if((self = [self init])) {
		self.address = [NSURL URLWithString:anAddress];
	}
	
	return self;
}
- (NSString *)MIMEType
{
	return @"text/xml";
}
- (void)addCookie:(NSHTTPCookie *)toAdd
{
	if(toAdd != nil) {
		if(cookies == nil) cookies = [[NSMutableArray alloc] init];
		[cookies addObject:toAdd];
	}
}
- (AuthenticateSoap11BindingResponse *)performSynchronousOperation:(AuthenticateSoap11BindingOperation *)operation
{
	synchronousOperationComplete = NO;
	[operation start];
	
	// Now wait for response
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	
	while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	return operation.response;
}
- (void)performAsynchronousOperation:(AuthenticateSoap11BindingOperation *)operation
{
	[operation start];
}
- (void) operation:(AuthenticateSoap11BindingOperation *)operation completedWithResponse:(AuthenticateSoap11BindingResponse *)response
{
	synchronousOperationComplete = YES;
}
- (AuthenticateSoap11BindingResponse *)processRemoteUsingParameters:(AuthenticateSvc_processRemote *)aParameters 
{
	return [self performSynchronousOperation:[[(AuthenticateSoap11Binding_processRemote*)[AuthenticateSoap11Binding_processRemote alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)processRemoteAsyncUsingParameters:(AuthenticateSvc_processRemote *)aParameters  delegate:(id<AuthenticateSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(AuthenticateSoap11Binding_processRemote*)[AuthenticateSoap11Binding_processRemote alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (void)sendHTTPCallUsingBody:(NSString *)outputBody soapAction:(NSString *)soapAction forOperation:(AuthenticateSoap11BindingOperation *)operation
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.address 
																												 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
																										 timeoutInterval:self.timeout];
	NSData *bodyData = [outputBody dataUsingEncoding:NSUTF8StringEncoding];
	
	if(cookies != nil) {
		[request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
	}
	[request setValue:@"wsdl2objc" forHTTPHeaderField:@"User-Agent"];
	[request setValue:soapAction forHTTPHeaderField:@"SOAPAction"];
	[request setValue:[[self MIMEType] stringByAppendingString:@"; charset=utf-8"] forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%u", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:self.address.host forHTTPHeaderField:@"Host"];
	for (NSString *eachHeaderField in [self.customHeaders allKeys]) {
		[request setValue:[self.customHeaders objectForKey:eachHeaderField] forHTTPHeaderField:eachHeaderField];
	}
	[request setHTTPMethod: @"POST"];
	// set version 1.1 - how?
	[request setHTTPBody: bodyData];
		
	if(self.logXMLInOut) {
		NSLog(@"OutputHeaders:\n%@", [request allHTTPHeaderFields]);
		NSLog(@"OutputBody:\n%@", outputBody);
	}
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:operation];
	
	operation.urlConnection = connection;
	[connection release];
}
- (void) addPointerForOperation:(AuthenticateSoap11BindingOperation *)operation
{
    NSValue *pointerValue = [NSValue valueWithNonretainedObject:operation];
    [self.operationPointers addObject:pointerValue];
}
- (void) removePointerForOperation:(AuthenticateSoap11BindingOperation *)operation
{
    NSIndexSet *matches = [self.operationPointers indexesOfObjectsPassingTest:^BOOL (id el, NSUInteger i, BOOL *stop) {
                               AuthenticateSoap11BindingOperation *op = [el nonretainedObjectValue];
                               return [op isEqual:operation];
                           }];
    [self.operationPointers removeObjectsAtIndexes:matches];
}
- (void) clearBindingOperations
{
    for (NSValue *pointerValue in self.operationPointers) {
        AuthenticateSoap11BindingOperation *operation = [pointerValue nonretainedObjectValue];
        [operation clear];
    }
}
- (void) dealloc
{
    [self clearBindingOperations];
	[address release];
	[cookies release];
	[customHeaders release];
	[authUsername release];
	[authPassword release];
    [operationPointers release];
	[super dealloc];
}
@end
@implementation AuthenticateSoap11BindingOperation
@synthesize binding;
@synthesize response;
@synthesize delegate;
@synthesize responseHeaders;
@synthesize responseData;
@synthesize serverDateDelta;
@synthesize urlConnection;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)aDelegate
{
	if ((self = [super init])) {
		self.binding = aBinding;
        [self.binding addPointerForOperation:self];
		response = nil;
		self.delegate = aDelegate;
		self.responseData = nil;
		self.urlConnection = nil;
	}
	
	return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential *newCredential;
		newCredential=[NSURLCredential credentialWithUser:self.binding.authUsername
												 password:self.binding.authPassword
											  persistence:NSURLCredentialPersistenceForSession];
		[[challenge sender] useCredential:newCredential
			   forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Authentication Error" forKey:NSLocalizedDescriptionKey];
		NSError *authError = [NSError errorWithDomain:@"Connection Authentication" code:0 userInfo:userInfo];
		[self connection:connection didFailWithError:authError];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)urlResponse
{
	NSHTTPURLResponse *httpResponse;
	if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
		httpResponse = (NSHTTPURLResponse *) urlResponse;
	} else {
		httpResponse = nil;
	}
	
	if(self.binding.logXMLInOut) {
		NSLog(@"ResponseStatus: %ld\n", (long)[httpResponse statusCode]);
		NSLog(@"ResponseHeaders:\n%@", [httpResponse allHeaderFields]);
	}
	self.responseHeaders = [httpResponse allHeaderFields];
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"]; 
	}
	NSDate *serverDate = [dateFormatter dateFromString:[self.responseHeaders objectForKey:@"Date"]];
	self.serverDateDelta = (serverDate == nil ? 0.0 : [serverDate timeIntervalSinceNow]);
	
	if ([urlResponse.MIMEType rangeOfString:[self.binding MIMEType]].length == 0) {
		NSError *error = nil;
		[connection cancel];
		if ([httpResponse statusCode] >= 400) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
				
			error = [NSError errorWithDomain:@"AuthenticateSoap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 												[NSString stringWithFormat: @"Unexpected response MIME type to SOAP call:%@", urlResponse.MIMEType],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
			error = [NSError errorWithDomain:@"AuthenticateSoap11BindingResponseHTTP" code:1 userInfo:userInfo];
		}
				
		[self connection:connection didFailWithError:error];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (responseData == nil) {
		responseData = [data mutableCopy];
	} else {
		[responseData appendData:data];
	}
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (binding.logXMLInOut) {
		NSLog(@"ResponseError:\n%@", error);
	}
	response.error = error;
	[delegate operation:self completedWithResponse:response];
}
- (void)dealloc
{
    [binding removePointerForOperation:self];
	[binding release];
	[response release];
	delegate = nil;
	[responseHeaders release];
	[responseData release];
	[urlConnection release];
	
	[super dealloc];
}
- (void)clear
{
    self.delegate = nil;
    [self.urlConnection cancel];
}
@end
@implementation AuthenticateSoap11Binding_processRemote
@synthesize parameters;
- (id)initWithBinding:(AuthenticateSoap11Binding *)aBinding delegate:(id<AuthenticateSoap11BindingResponseDelegate>)responseDelegate
parameters:(AuthenticateSvc_processRemote *)aParameters
{
	if((self = [super initWithBinding:aBinding delegate:responseDelegate])) {
		self.parameters = aParameters;
	}
	
	return self;
}
- (void)dealloc
{
	if(parameters != nil) [parameters release];
	
	[super dealloc];
}
- (void)main
{
	[response autorelease];
	response = [AuthenticateSoap11BindingResponse new];
	
	AuthenticateSoap11Binding_envelope *envelope = [AuthenticateSoap11Binding_envelope sharedInstance];
	
	NSMutableDictionary *headerElements = nil;
	headerElements = [NSMutableDictionary dictionary];
	
	NSMutableDictionary *bodyElements = nil;
	NSMutableArray *bodyKeys = nil;
	bodyElements = [NSMutableDictionary dictionary];
	bodyKeys = [NSMutableArray array];
	id obj;
	obj = nil;
	if(parameters != nil) obj = parameters;
	if(obj != nil) {
		[bodyElements setObject:obj forKey:@"processRemote"];
		[bodyKeys addObject:@"processRemote"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:processRemote" forOperation:self];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (responseData != nil && delegate != nil)
	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			xmlDocPtr doc;
			xmlNodePtr cur;
		
			if (binding.logXMLInOut) {
				NSLog(@"ResponseBody:\n%@", [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
			}
		
#if !TARGET_OS_IPHONE && (!defined(MAC_OS_X_VERSION_10_6) || MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6)
	// Not yet defined in 10.5 libxml
	#define XML_PARSE_COMPACT 0
#endif
			doc = xmlReadMemory([responseData bytes], [responseData length], NULL, NULL, XML_PARSE_COMPACT | XML_PARSE_NOBLANKS);
		
			if (doc == NULL) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Errors while parsing returned XML" forKey:NSLocalizedDescriptionKey];
			
				response.error = [NSError errorWithDomain:@"AuthenticateSoap11BindingResponseXML" code:1 userInfo:userInfo];
			} else {
				cur = xmlDocGetRootElement(doc);
				cur = cur->children;
			
				for( ; cur != NULL ; cur = cur->next) {
					if(cur->type == XML_ELEMENT_NODE) {
					
						if(xmlStrEqual(cur->name, (const xmlChar *) "Body")) {
							NSMutableArray *responseBodyParts = [NSMutableArray array];
						
							xmlNodePtr bodyNode;
							for(bodyNode=cur->children ; bodyNode != NULL ; bodyNode = bodyNode->next) {
								if(cur->type == XML_ELEMENT_NODE) {
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "processRemoteResponse")) {
										AuthenticateSvc_processRemoteResponse *bodyObject = [AuthenticateSvc_processRemoteResponse deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
									if ((bodyNode->ns != nil && xmlStrEqual(bodyNode->ns->prefix, cur->ns->prefix)) && 
										xmlStrEqual(bodyNode->name, (const xmlChar *) "Fault")) {
										SOAPFault *bodyObject = [SOAPFault deserializeNode:bodyNode];
										//NSAssert1(bodyObject != nil, @"Errors while parsing body %s", bodyNode->name);
										if (bodyObject != nil) [responseBodyParts addObject:bodyObject];
									}
								}
							}
						
							response.bodyParts = responseBodyParts;
						}
					}
				}
			
				xmlFreeDoc(doc);
			}
			if(delegate != nil && [delegate respondsToSelector:@selector(operation:completedWithResponse:)] == YES) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[delegate operation:self completedWithResponse:response];
				});
			}
		});
	}
}
@end
static AuthenticateSoap11Binding_envelope *AuthenticateSoap11BindingSharedEnvelopeInstance = nil;
@implementation AuthenticateSoap11Binding_envelope
+ (AuthenticateSoap11Binding_envelope *)sharedInstance
{
	if(AuthenticateSoap11BindingSharedEnvelopeInstance == nil) {
		AuthenticateSoap11BindingSharedEnvelopeInstance = [AuthenticateSoap11Binding_envelope new];
	}
	
	return AuthenticateSoap11BindingSharedEnvelopeInstance;
}
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys
{
	xmlDocPtr doc;
	
	doc = xmlNewDoc((const xmlChar*)XML_DEFAULT_VERSION);
	if (doc == NULL) {
		NSLog(@"Error creating the xml document tree");
		return @"";
	}
	
	xmlNodePtr root = xmlNewDocNode(doc, NULL, (const xmlChar*)"Envelope", NULL);
	xmlDocSetRootElement(doc, root);
	
	xmlNsPtr soapEnvelopeNs = xmlNewNs(root, (const xmlChar*)"http://schemas.xmlsoap.org/soap/envelope/", (const xmlChar*)"soap");
	xmlSetNs(root, soapEnvelopeNs);
	
	xmlNsPtr xslNs = xmlNewNs(root, (const xmlChar*)"http://www.w3.org/1999/XSL/Transform", (const xmlChar*)"xsl");
	xmlNewNs(root, (const xmlChar*)"http://www.w3.org/2001/XMLSchema-instance", (const xmlChar*)"xsi");
	
	xmlNewNsProp(root, xslNs, (const xmlChar*)"version", (const xmlChar*)"1.0");
	
	xmlNewNs(root, (const xmlChar*)"http://www.w3.org/2001/XMLSchema", (const xmlChar*)"xsd");
	xmlNewNs(root, (const xmlChar*)"http://sps.schws.scholastic.com", (const xmlChar*)"AuthenticateSvc");
	
	if((headerElements != nil) && ([headerElements count] > 0)) {
		xmlNodePtr headerNode = xmlNewDocNode(doc, soapEnvelopeNs, (const xmlChar*)"Header", NULL);
		xmlAddChild(root, headerNode);
		
		for(NSString *key in [headerElements allKeys]) {
			id header = [headerElements objectForKey:key];
			xmlAddChild(headerNode, [header xmlNodeForDoc:doc elementName:key elementNSPrefix:nil]);
		}
	}
	
	if((bodyElements != nil) && ([bodyElements count] > 0)) {
		xmlNodePtr bodyNode = xmlNewDocNode(doc, soapEnvelopeNs, (const xmlChar*)"Body", NULL);
		xmlAddChild(root, bodyNode);
		
		for(NSString *key in bodyKeys) {
			id body = [bodyElements objectForKey:key];
			xmlAddChild(bodyNode, [body xmlNodeForDoc:doc elementName:key elementNSPrefix:nil]);
		}
	}
	
	xmlChar *buf;
	int size;
	xmlDocDumpFormatMemory(doc, &buf, &size, 1);
	
	NSString *serializedForm = [NSString stringWithCString:(const char*)buf encoding:NSUTF8StringEncoding];
	xmlFree(buf);
	
	xmlFreeDoc(doc);	
	return serializedForm;
}
@end
@implementation AuthenticateSoap11BindingResponse
@synthesize headers;
@synthesize bodyParts;
@synthesize error;
- (id)init
{
	if((self = [super init])) {
		headers = nil;
		bodyParts = nil;
		error = nil;
	}
	
	return self;
}
- (void)dealloc {
	self.headers = nil;
	self.bodyParts = nil;
	self.error = nil;	
	[super dealloc];
}
@end
