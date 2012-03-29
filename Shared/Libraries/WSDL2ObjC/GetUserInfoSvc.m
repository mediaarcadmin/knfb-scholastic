#import "GetUserInfoSvc.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
@implementation GetUserInfoSvc_processRemote
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
	return @"GetUserInfoSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"GetUserInfoSvc", elName];
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
		xmlAddChild(node, [self.SPSWSXML xmlNodeForDoc:node->doc elementName:@"SPSWSXML" elementNSPrefix:@"GetUserInfoSvc"]);
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
+ (GetUserInfoSvc_processRemote *)deserializeNode:(xmlNodePtr)cur
{
	GetUserInfoSvc_processRemote *newObject = [[GetUserInfoSvc_processRemote new] autorelease];
	
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
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	//if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
	//	self = [(id)super initWithCoder:decoder];
	//} else {
		self = [super init];
	//}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [decoder decodeObjectForKey:key];
		if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
		[self setValue:value forKey:key];
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
		id value = [self valueForKey:key];
		[encoder encodeObject:value forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation GetUserInfoSvc_processRemoteResponse
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
	return @"GetUserInfoSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"GetUserInfoSvc", elName];
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
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"GetUserInfoSvc"]);
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
+ (GetUserInfoSvc_processRemoteResponse *)deserializeNode:(xmlNodePtr)cur
{
	GetUserInfoSvc_processRemoteResponse *newObject = [[GetUserInfoSvc_processRemoteResponse new] autorelease];
	
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
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	//if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
	//	self = [(id)super initWithCoder:decoder];
	//} else {
		self = [super init];
	//}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [decoder decodeObjectForKey:key];
		if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
		[self setValue:value forKey:key];
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
		id value = [self valueForKey:key];
		[encoder encodeObject:value forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation GetUserInfoSvc_SchWSException
- (id)init
{
	if((self = [super init])) {
		SchWSException = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(SchWSException != nil) [SchWSException release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"GetUserInfoSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"GetUserInfoSvc", elName];
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
	
	if(self.SchWSException != 0) {
		xmlAddChild(node, [self.SchWSException xmlNodeForDoc:node->doc elementName:@"SchWSException" elementNSPrefix:@"GetUserInfoSvc"]);
	}
}
/* elements */
@synthesize SchWSException;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (GetUserInfoSvc_SchWSException *)deserializeNode:(xmlNodePtr)cur
{
	GetUserInfoSvc_SchWSException *newObject = [[GetUserInfoSvc_SchWSException new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "SchWSException")) {
				
				Class elementClass = nil;
				xmlChar *instanceType = xmlGetNsProp(cur, (const xmlChar *) "type", (const xmlChar *) "http://www.w3.org/2001/XMLSchema-instance");
				if(instanceType == NULL) {
					elementClass = [ax25_SchWSException class];
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
				
				self.SchWSException = newChild;
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	//if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
	//	self = [(id)super initWithCoder:decoder];
	//} else {
		self = [super init];
	//}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [decoder decodeObjectForKey:key];
		if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
		[self setValue:value forKey:key];
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
		id value = [self valueForKey:key];
		[encoder encodeObject:value forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation GetUserInfoSvc_checkIfValidPropertyRequested
- (id)init
{
	if((self = [super init])) {
		name = 0;
		clientID = 0;
		serviceName = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(name != nil) [name release];
	if(clientID != nil) [clientID release];
	if(serviceName != nil) [serviceName release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"GetUserInfoSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"GetUserInfoSvc", elName];
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
	
	if(self.name != 0) {
		xmlAddChild(node, [self.name xmlNodeForDoc:node->doc elementName:@"name" elementNSPrefix:@"GetUserInfoSvc"]);
	}
	if(self.clientID != 0) {
		xmlAddChild(node, [self.clientID xmlNodeForDoc:node->doc elementName:@"clientID" elementNSPrefix:@"GetUserInfoSvc"]);
	}
	if(self.serviceName != 0) {
		xmlAddChild(node, [self.serviceName xmlNodeForDoc:node->doc elementName:@"serviceName" elementNSPrefix:@"GetUserInfoSvc"]);
	}
}
/* elements */
@synthesize name;
@synthesize clientID;
@synthesize serviceName;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (GetUserInfoSvc_checkIfValidPropertyRequested *)deserializeNode:(xmlNodePtr)cur
{
	GetUserInfoSvc_checkIfValidPropertyRequested *newObject = [[GetUserInfoSvc_checkIfValidPropertyRequested new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "name")) {
				
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
				
				self.name = newChild;
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "clientID")) {
				
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
				
				self.clientID = newChild;
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "serviceName")) {
				
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
				
				self.serviceName = newChild;
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	//if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
	//	self = [(id)super initWithCoder:decoder];
	//} else {
		self = [super init];
	//}
	if (self == nil) { return nil; }
 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	unsigned int numIvars = 0;
	Ivar * ivars = class_copyIvarList([self class], &numIvars);
	for(int i = 0; i < numIvars; i++) {
		Ivar thisIvar = ivars[i];
		NSString * key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
		id value = [decoder decodeObjectForKey:key];
		if (value == nil) { value = [NSNumber numberWithFloat:0.0]; }
		[self setValue:value forKey:key];
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
		id value = [self valueForKey:key];
		[encoder encodeObject:value forKey:key];
	}
	if (numIvars > 0) { free(ivars); }
	[pool drain];
}
@end
@implementation GetUserInfoSvc
+ (void)initialize
{
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"xsd" forKey:@"http://www.w3.org/2001/XMLSchema"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"GetUserInfoSvc" forKey:@"http://sps.schws.scholastic.com"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"ax25" forKey:@"http://utils.sps.schws.scholastic.com/xsd"];
}
+ (GetUserInfoSoap11Binding *)GetUserInfoSoap11Binding
{
	return [[[GetUserInfoSoap11Binding alloc] initWithAddress:@"http://esvcsqa.scholastic.com/SchWS/services/SPS/GetUserInfo.GetUserInfoHttpSoap11Endpoint/"] autorelease];
}
@end
@implementation GetUserInfoSoap11Binding
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
- (GetUserInfoSoap11BindingResponse *)performSynchronousOperation:(GetUserInfoSoap11BindingOperation *)operation
{
	synchronousOperationComplete = NO;
	[operation start];
	
	// Now wait for response
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	
	while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	return operation.response;
}
- (void)performAsynchronousOperation:(GetUserInfoSoap11BindingOperation *)operation
{
	[operation start];
}
- (void) operation:(GetUserInfoSoap11BindingOperation *)operation completedWithResponse:(GetUserInfoSoap11BindingResponse *)response
{
	synchronousOperationComplete = YES;
}
- (GetUserInfoSoap11BindingResponse *)checkIfValidPropertyRequestedUsingParameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters 
{
	return [self performSynchronousOperation:[[(GetUserInfoSoap11Binding_checkIfValidPropertyRequested*)[GetUserInfoSoap11Binding_checkIfValidPropertyRequested alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)checkIfValidPropertyRequestedAsyncUsingParameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters  delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(GetUserInfoSoap11Binding_checkIfValidPropertyRequested*)[GetUserInfoSoap11Binding_checkIfValidPropertyRequested alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (GetUserInfoSoap11BindingResponse *)processRemoteUsingParameters:(GetUserInfoSvc_processRemote *)aParameters 
{
	return [self performSynchronousOperation:[[(GetUserInfoSoap11Binding_processRemote*)[GetUserInfoSoap11Binding_processRemote alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)processRemoteAsyncUsingParameters:(GetUserInfoSvc_processRemote *)aParameters  delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(GetUserInfoSoap11Binding_processRemote*)[GetUserInfoSoap11Binding_processRemote alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (void)sendHTTPCallUsingBody:(NSString *)outputBody soapAction:(NSString *)soapAction forOperation:(GetUserInfoSoap11BindingOperation *)operation
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
- (void) addPointerForOperation:(GetUserInfoSoap11BindingOperation *)operation
{
    NSValue *pointerValue = [NSValue valueWithNonretainedObject:operation];
    [self.operationPointers addObject:pointerValue];
}
- (void) removePointerForOperation:(GetUserInfoSoap11BindingOperation *)operation
{
    NSIndexSet *matches = [self.operationPointers indexesOfObjectsPassingTest:^BOOL (id el, NSUInteger i, BOOL *stop) {
                               GetUserInfoSoap11BindingOperation *op = [el nonretainedObjectValue];
                               return [op isEqual:operation];
                           }];
    [self.operationPointers removeObjectsAtIndexes:matches];
}
- (void) clearBindingOperations
{
    for (NSValue *pointerValue in self.operationPointers) {
        GetUserInfoSoap11BindingOperation *operation = [pointerValue nonretainedObjectValue];
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
@implementation GetUserInfoSoap11BindingOperation
@synthesize binding;
@synthesize response;
@synthesize delegate;
@synthesize responseHeaders;
@synthesize responseData;
@synthesize serverDateDelta;
@synthesize urlConnection;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)aDelegate
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
				
			error = [NSError errorWithDomain:@"GetUserInfoSoap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 												[NSString stringWithFormat: @"Unexpected response MIME type to SOAP call:%@", urlResponse.MIMEType],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
			error = [NSError errorWithDomain:@"GetUserInfoSoap11BindingResponseHTTP" code:1 userInfo:userInfo];
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
@implementation GetUserInfoSoap11Binding_checkIfValidPropertyRequested
@synthesize parameters;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate
parameters:(GetUserInfoSvc_checkIfValidPropertyRequested *)aParameters
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
	response = [GetUserInfoSoap11BindingResponse new];
	
	GetUserInfoSoap11Binding_envelope *envelope = [GetUserInfoSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"checkIfValidPropertyRequested"];
		[bodyKeys addObject:@"checkIfValidPropertyRequested"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:checkIfValidPropertyRequested" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"GetUserInfoSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
@implementation GetUserInfoSoap11Binding_processRemote
@synthesize parameters;
- (id)initWithBinding:(GetUserInfoSoap11Binding *)aBinding delegate:(id<GetUserInfoSoap11BindingResponseDelegate>)responseDelegate
parameters:(GetUserInfoSvc_processRemote *)aParameters
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
	response = [GetUserInfoSoap11BindingResponse new];
	
	GetUserInfoSoap11Binding_envelope *envelope = [GetUserInfoSoap11Binding_envelope sharedInstance];
	
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
			
				response.error = [NSError errorWithDomain:@"GetUserInfoSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
										GetUserInfoSvc_processRemoteResponse *bodyObject = [GetUserInfoSvc_processRemoteResponse deserializeNode:bodyNode];
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
static GetUserInfoSoap11Binding_envelope *GetUserInfoSoap11BindingSharedEnvelopeInstance = nil;
@implementation GetUserInfoSoap11Binding_envelope
+ (GetUserInfoSoap11Binding_envelope *)sharedInstance
{
	if(GetUserInfoSoap11BindingSharedEnvelopeInstance == nil) {
		GetUserInfoSoap11BindingSharedEnvelopeInstance = [GetUserInfoSoap11Binding_envelope new];
	}
	
	return GetUserInfoSoap11BindingSharedEnvelopeInstance;
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
	xmlNewNs(root, (const xmlChar*)"http://sps.schws.scholastic.com", (const xmlChar*)"GetUserInfoSvc");
	xmlNewNs(root, (const xmlChar*)"http://utils.sps.schws.scholastic.com/xsd", (const xmlChar*)"ax25");
	
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
@implementation GetUserInfoSoap11BindingResponse
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
