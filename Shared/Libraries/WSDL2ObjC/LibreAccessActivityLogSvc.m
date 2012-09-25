// No version information in WSDL

#import "LibreAccessActivityLogSvc.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
LibreAccessActivityLogSvc_statuscodes LibreAccessActivityLogSvc_statuscodes_enumFromString(NSString *string)
{
	if([string isEqualToString:@"SUCCESS"]) {
		return LibreAccessActivityLogSvc_statuscodes_SUCCESS;
	}
	if([string isEqualToString:@"FAIL"]) {
		return LibreAccessActivityLogSvc_statuscodes_FAIL;
	}
	
	return LibreAccessActivityLogSvc_statuscodes_none;
}
NSString * LibreAccessActivityLogSvc_statuscodes_stringFromEnum(LibreAccessActivityLogSvc_statuscodes enumValue)
{
	switch (enumValue) {
		case LibreAccessActivityLogSvc_statuscodes_SUCCESS:
			return @"SUCCESS";
			break;
		case LibreAccessActivityLogSvc_statuscodes_FAIL:
			return @"FAIL";
			break;
		default:
			return @"";
	}
}
@implementation LibreAccessActivityLogSvc_ItemsCount
- (id)init
{
	if((self = [super init])) {
		Returned = 0;
		Found = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(Returned != nil) [Returned release];
	if(Found != nil) [Found release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.Returned != 0) {
		xmlAddChild(node, [self.Returned xmlNodeForDoc:node->doc elementName:@"Returned" elementNSPrefix:nil]);
	}
	if(self.Found != 0) {
		xmlAddChild(node, [self.Found xmlNodeForDoc:node->doc elementName:@"Found" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize Returned;
@synthesize Found;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ItemsCount *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ItemsCount *newObject = [[LibreAccessActivityLogSvc_ItemsCount new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "Returned")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.Returned = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "Found")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.Found = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_StatusHolder
- (id)init
{
	if((self = [super init])) {
		status = 0;
		statuscode = 0;
		statusmessage = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statuscode != nil) [statuscode release];
	if(statusmessage != nil) [statusmessage release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.status != 0) {
		xmlNewChild(node, NULL, (const xmlChar*)"status", [LibreAccessActivityLogSvc_statuscodes_stringFromEnum(self.status) xmlString]);
	}
	if(self.statuscode != 0) {
		xmlAddChild(node, [self.statuscode xmlNodeForDoc:node->doc elementName:@"statuscode" elementNSPrefix:nil]);
	}
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize status;
@synthesize statuscode;
@synthesize statusmessage;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_StatusHolder *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_StatusHolder *newObject = [[LibreAccessActivityLogSvc_StatusHolder new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "status")) {
				
				LibreAccessActivityLogSvc_statuscodes enumRepresentation = LibreAccessActivityLogSvc_statuscodes_enumFromString(elementString);
				self.status = enumRepresentation;
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "statuscode")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.statuscode = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
				
                    self.statusmessage = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_SaveDumpItem
- (id)init
{
	if((self = [super init])) {
		CDATA = 0;
		timestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(CDATA != nil) [CDATA release];
	if(timestamp != nil) [timestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.CDATA != 0) {
		xmlAddChild(node, [self.CDATA xmlNodeForDoc:node->doc elementName:@"CDATA" elementNSPrefix:nil]);
	}
	if(self.timestamp != 0) {
		xmlAddChild(node, [self.timestamp xmlNodeForDoc:node->doc elementName:@"timestamp" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize CDATA;
@synthesize timestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveDumpItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveDumpItem *newObject = [[LibreAccessActivityLogSvc_SaveDumpItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "CDATA")) {
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
				
                    self.CDATA = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "timestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.timestamp = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_SaveDumpItemsList
- (id)init
{
	if((self = [super init])) {
		saveDumpItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(saveDumpItem != nil) [saveDumpItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.saveDumpItem != 0) {
		for(LibreAccessActivityLogSvc_SaveDumpItem * child in self.saveDumpItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"saveDumpItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize saveDumpItem;
- (void)addSaveDumpItem:(LibreAccessActivityLogSvc_SaveDumpItem *)toAdd
{
	if(toAdd != nil) [saveDumpItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveDumpItemsList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveDumpItemsList *newObject = [[LibreAccessActivityLogSvc_SaveDumpItemsList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "saveDumpItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_SaveDumpItem class];
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
				
                    if(newChild != nil) [self.saveDumpItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_SaveDump
- (id)init
{
	if((self = [super init])) {
		authToken = 0;
		dumpItemsList = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(authToken != nil) [authToken release];
	if(dumpItemsList != nil) [dumpItemsList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.authToken != 0) {
		xmlAddChild(node, [self.authToken xmlNodeForDoc:node->doc elementName:@"authToken" elementNSPrefix:nil]);
	}
	if(self.dumpItemsList != 0) {
		xmlAddChild(node, [self.dumpItemsList xmlNodeForDoc:node->doc elementName:@"dumpItemsList" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize authToken;
@synthesize dumpItemsList;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveDump *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveDump *newObject = [[LibreAccessActivityLogSvc_SaveDump new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "authToken")) {
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
				
                    self.authToken = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "dumpItemsList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_SaveDumpItemsList class];
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
				
                    self.dumpItemsList = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_SaveDumpResponse
- (id)init
{
	if((self = [super init])) {
		statusmessage = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusmessage != nil) [statusmessage release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusmessage;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveDumpResponse *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveDumpResponse *newObject = [[LibreAccessActivityLogSvc_SaveDumpResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
                        elementClass = [LibreAccessActivityLogSvc_StatusHolder class];
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
				
                    self.statusmessage = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_ListDump
- (id)init
{
	if((self = [super init])) {
		CSRtoken = 0;
		countLastDumpsToBeReturned = 0;
		applicationId = 0;
		deviceKey = 0;
		userKey = 0;
		minTimestamp = 0;
		maxTimestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(CSRtoken != nil) [CSRtoken release];
	if(countLastDumpsToBeReturned != nil) [countLastDumpsToBeReturned release];
	if(applicationId != nil) [applicationId release];
	if(deviceKey != nil) [deviceKey release];
	if(userKey != nil) [userKey release];
	if(minTimestamp != nil) [minTimestamp release];
	if(maxTimestamp != nil) [maxTimestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.CSRtoken != 0) {
		xmlAddChild(node, [self.CSRtoken xmlNodeForDoc:node->doc elementName:@"CSRtoken" elementNSPrefix:nil]);
	}
	if(self.countLastDumpsToBeReturned != 0) {
		xmlAddChild(node, [self.countLastDumpsToBeReturned xmlNodeForDoc:node->doc elementName:@"countLastDumpsToBeReturned" elementNSPrefix:nil]);
	}
	if(self.applicationId != 0) {
		xmlAddChild(node, [self.applicationId xmlNodeForDoc:node->doc elementName:@"applicationId" elementNSPrefix:nil]);
	}
	if(self.deviceKey != 0) {
		xmlAddChild(node, [self.deviceKey xmlNodeForDoc:node->doc elementName:@"deviceKey" elementNSPrefix:nil]);
	}
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.minTimestamp != 0) {
		xmlAddChild(node, [self.minTimestamp xmlNodeForDoc:node->doc elementName:@"minTimestamp" elementNSPrefix:nil]);
	}
	if(self.maxTimestamp != 0) {
		xmlAddChild(node, [self.maxTimestamp xmlNodeForDoc:node->doc elementName:@"maxTimestamp" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize CSRtoken;
@synthesize countLastDumpsToBeReturned;
@synthesize applicationId;
@synthesize deviceKey;
@synthesize userKey;
@synthesize minTimestamp;
@synthesize maxTimestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListDump *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListDump *newObject = [[LibreAccessActivityLogSvc_ListDump new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "CSRtoken")) {
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
				
                    self.CSRtoken = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "countLastDumpsToBeReturned")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.countLastDumpsToBeReturned = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "applicationId")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.applicationId = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "deviceKey")) {
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
				
                    self.deviceKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "minTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.minTimestamp = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "maxTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.maxTimestamp = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_DumpItem
- (id)init
{
	if((self = [super init])) {
		userKey = 0;
		deviceKey = 0;
		CDATA = 0;
		timestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(userKey != nil) [userKey release];
	if(deviceKey != nil) [deviceKey release];
	if(CDATA != nil) [CDATA release];
	if(timestamp != nil) [timestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.deviceKey != 0) {
		xmlAddChild(node, [self.deviceKey xmlNodeForDoc:node->doc elementName:@"deviceKey" elementNSPrefix:nil]);
	}
	if(self.CDATA != 0) {
		xmlAddChild(node, [self.CDATA xmlNodeForDoc:node->doc elementName:@"CDATA" elementNSPrefix:nil]);
	}
	if(self.timestamp != 0) {
		xmlAddChild(node, [self.timestamp xmlNodeForDoc:node->doc elementName:@"timestamp" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize userKey;
@synthesize deviceKey;
@synthesize CDATA;
@synthesize timestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_DumpItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_DumpItem *newObject = [[LibreAccessActivityLogSvc_DumpItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "deviceKey")) {
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
				
                    self.deviceKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "CDATA")) {
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
				
                    self.CDATA = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "timestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.timestamp = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_DumpList
- (id)init
{
	if((self = [super init])) {
		dumpItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(dumpItem != nil) [dumpItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.dumpItem != 0) {
		for(LibreAccessActivityLogSvc_DumpItem * child in self.dumpItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"dumpItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize dumpItem;
- (void)addDumpItem:(LibreAccessActivityLogSvc_DumpItem *)toAdd
{
	if(toAdd != nil) [dumpItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_DumpList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_DumpList *newObject = [[LibreAccessActivityLogSvc_DumpList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "dumpItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_DumpItem class];
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
				
                    if(newChild != nil) [self.dumpItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ListDumpResponse
- (id)init
{
	if((self = [super init])) {
		statusmessage = 0;
		dumpList = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusmessage != nil) [statusmessage release];
	if(dumpList != nil) [dumpList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
	if(self.dumpList != 0) {
		xmlAddChild(node, [self.dumpList xmlNodeForDoc:node->doc elementName:@"dumpList" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusmessage;
@synthesize dumpList;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListDumpResponse *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListDumpResponse *newObject = [[LibreAccessActivityLogSvc_ListDumpResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
                        elementClass = [LibreAccessActivityLogSvc_StatusHolder class];
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
				
                    self.statusmessage = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "dumpList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_DumpList class];
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
				
                    self.dumpList = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_LogItem
- (id)init
{
	if((self = [super init])) {
		definitionName = 0;
		value = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(definitionName != nil) [definitionName release];
	if(value != nil) [value release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.definitionName != 0) {
		xmlAddChild(node, [self.definitionName xmlNodeForDoc:node->doc elementName:@"definitionName" elementNSPrefix:nil]);
	}
	if(self.value != 0) {
		xmlAddChild(node, [self.value xmlNodeForDoc:node->doc elementName:@"value" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize definitionName;
@synthesize value;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_LogItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_LogItem *newObject = [[LibreAccessActivityLogSvc_LogItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "definitionName")) {
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
				
                    self.definitionName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "value")) {
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
				
                    self.value = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_LogsList
- (id)init
{
	if((self = [super init])) {
		activityName = 0;
		correlationID = 0;
		logItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(activityName != nil) [activityName release];
	if(correlationID != nil) [correlationID release];
	if(logItem != nil) [logItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityName != 0) {
		xmlAddChild(node, [self.activityName xmlNodeForDoc:node->doc elementName:@"activityName" elementNSPrefix:nil]);
	}
	if(self.correlationID != 0) {
		xmlAddChild(node, [self.correlationID xmlNodeForDoc:node->doc elementName:@"correlationID" elementNSPrefix:nil]);
	}
	if(self.logItem != 0) {
		for(LibreAccessActivityLogSvc_LogItem * child in self.logItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"logItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize activityName;
@synthesize correlationID;
@synthesize logItem;
- (void)addLogItem:(LibreAccessActivityLogSvc_LogItem *)toAdd
{
	if(toAdd != nil) [logItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_LogsList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_LogsList *newObject = [[LibreAccessActivityLogSvc_LogsList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityName")) {
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
				
                    self.activityName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "correlationID")) {
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
				
                    self.correlationID = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "logItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_LogItem class];
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
				
                    if(newChild != nil) [self.logItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_SaveActivityLog
- (id)init
{
	if((self = [super init])) {
		authToken = 0;
		userKey = 0;
		logsList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(authToken != nil) [authToken release];
	if(userKey != nil) [userKey release];
	if(logsList != nil) [logsList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.authToken != 0) {
		xmlAddChild(node, [self.authToken xmlNodeForDoc:node->doc elementName:@"authToken" elementNSPrefix:nil]);
	}
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.logsList != 0) {
		for(LibreAccessActivityLogSvc_LogsList * child in self.logsList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"logsList" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize authToken;
@synthesize userKey;
@synthesize logsList;
- (void)addLogsList:(LibreAccessActivityLogSvc_LogsList *)toAdd
{
	if(toAdd != nil) [logsList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveActivityLog *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveActivityLog *newObject = [[LibreAccessActivityLogSvc_SaveActivityLog new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "authToken")) {
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
				
                    self.authToken = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "logsList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_LogsList class];
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
				
                    if(newChild != nil) [self.logsList addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_SavedItem
- (id)init
{
	if((self = [super init])) {
		correlationID = 0;
		activityFactID = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(correlationID != nil) [correlationID release];
	if(activityFactID != nil) [activityFactID release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.correlationID != 0) {
		xmlAddChild(node, [self.correlationID xmlNodeForDoc:node->doc elementName:@"correlationID" elementNSPrefix:nil]);
	}
	if(self.activityFactID != 0) {
		xmlAddChild(node, [self.activityFactID xmlNodeForDoc:node->doc elementName:@"activityFactID" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize correlationID;
@synthesize activityFactID;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SavedItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SavedItem *newObject = [[LibreAccessActivityLogSvc_SavedItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "correlationID")) {
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
				
                    self.correlationID = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityFactID")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.activityFactID = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_SavedIdsList
- (id)init
{
	if((self = [super init])) {
		savedItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(savedItem != nil) [savedItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.savedItem != 0) {
		for(LibreAccessActivityLogSvc_SavedItem * child in self.savedItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"savedItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize savedItem;
- (void)addSavedItem:(LibreAccessActivityLogSvc_SavedItem *)toAdd
{
	if(toAdd != nil) [savedItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SavedIdsList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SavedIdsList *newObject = [[LibreAccessActivityLogSvc_SavedIdsList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "savedItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_SavedItem class];
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
				
                    if(newChild != nil) [self.savedItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_SaveActivityLogResponse
- (id)init
{
	if((self = [super init])) {
		statusmessage = 0;
		savedIdsList = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusmessage != nil) [statusmessage release];
	if(savedIdsList != nil) [savedIdsList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
	if(self.savedIdsList != 0) {
		xmlAddChild(node, [self.savedIdsList xmlNodeForDoc:node->doc elementName:@"savedIdsList" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusmessage;
@synthesize savedIdsList;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_SaveActivityLogResponse *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_SaveActivityLogResponse *newObject = [[LibreAccessActivityLogSvc_SaveActivityLogResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
                        elementClass = [LibreAccessActivityLogSvc_StatusHolder class];
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
				
                    self.statusmessage = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "savedIdsList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_SavedIdsList class];
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
				
                    self.savedIdsList = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_FilterItem
- (id)init
{
	if((self = [super init])) {
		definitionName = 0;
		activityLogValue = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(definitionName != nil) [definitionName release];
	if(activityLogValue != nil) [activityLogValue release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.definitionName != 0) {
		xmlAddChild(node, [self.definitionName xmlNodeForDoc:node->doc elementName:@"definitionName" elementNSPrefix:nil]);
	}
	if(self.activityLogValue != 0) {
		xmlAddChild(node, [self.activityLogValue xmlNodeForDoc:node->doc elementName:@"activityLogValue" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize definitionName;
@synthesize activityLogValue;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_FilterItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_FilterItem *newObject = [[LibreAccessActivityLogSvc_FilterItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "definitionName")) {
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
				
                    self.definitionName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogValue")) {
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
				
                    self.activityLogValue = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_Filters
- (id)init
{
	if((self = [super init])) {
		filter = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(filter != nil) [filter release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.filter != 0) {
		for(LibreAccessActivityLogSvc_FilterItem * child in self.filter) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"filter" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize filter;
- (void)addFilter:(LibreAccessActivityLogSvc_FilterItem *)toAdd
{
	if(toAdd != nil) [filter addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_Filters *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_Filters *newObject = [[LibreAccessActivityLogSvc_Filters new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "filter")) {
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
                        elementClass = [LibreAccessActivityLogSvc_FilterItem class];
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
				
                    if(newChild != nil) [self.filter addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ListActivityLog
- (id)init
{
	if((self = [super init])) {
		CSRtoken = 0;
		activityMasterName = 0;
		itemsCountToBeReturned = 0;
		userKey = 0;
		minTimestamp = 0;
		maxTimestamp = 0;
		filters = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(CSRtoken != nil) [CSRtoken release];
	if(activityMasterName != nil) [activityMasterName release];
	if(itemsCountToBeReturned != nil) [itemsCountToBeReturned release];
	if(userKey != nil) [userKey release];
	if(minTimestamp != nil) [minTimestamp release];
	if(maxTimestamp != nil) [maxTimestamp release];
	if(filters != nil) [filters release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.CSRtoken != 0) {
		xmlAddChild(node, [self.CSRtoken xmlNodeForDoc:node->doc elementName:@"CSRtoken" elementNSPrefix:nil]);
	}
	if(self.activityMasterName != 0) {
		xmlAddChild(node, [self.activityMasterName xmlNodeForDoc:node->doc elementName:@"activityMasterName" elementNSPrefix:nil]);
	}
	if(self.itemsCountToBeReturned != 0) {
		xmlAddChild(node, [self.itemsCountToBeReturned xmlNodeForDoc:node->doc elementName:@"itemsCountToBeReturned" elementNSPrefix:nil]);
	}
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.minTimestamp != 0) {
		xmlAddChild(node, [self.minTimestamp xmlNodeForDoc:node->doc elementName:@"minTimestamp" elementNSPrefix:nil]);
	}
	if(self.maxTimestamp != 0) {
		xmlAddChild(node, [self.maxTimestamp xmlNodeForDoc:node->doc elementName:@"maxTimestamp" elementNSPrefix:nil]);
	}
	if(self.filters != 0) {
		xmlAddChild(node, [self.filters xmlNodeForDoc:node->doc elementName:@"filters" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize CSRtoken;
@synthesize activityMasterName;
@synthesize itemsCountToBeReturned;
@synthesize userKey;
@synthesize minTimestamp;
@synthesize maxTimestamp;
@synthesize filters;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListActivityLog *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListActivityLog *newObject = [[LibreAccessActivityLogSvc_ListActivityLog new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "CSRtoken")) {
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
				
                    self.CSRtoken = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityMasterName")) {
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
				
                    self.activityMasterName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "itemsCountToBeReturned")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.itemsCountToBeReturned = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "minTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.minTimestamp = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "maxTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.maxTimestamp = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "filters")) {
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
                        elementClass = [LibreAccessActivityLogSvc_Filters class];
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
				
                    self.filters = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_ActivityLogDetailItem
- (id)init
{
	if((self = [super init])) {
		activityLogDefinitionID = 0;
		activityLogDefinitionName = 0;
		activityLogDefinitionDesc = 0;
		value = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(activityLogDefinitionID != nil) [activityLogDefinitionID release];
	if(activityLogDefinitionName != nil) [activityLogDefinitionName release];
	if(activityLogDefinitionDesc != nil) [activityLogDefinitionDesc release];
	if(value != nil) [value release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityLogDefinitionID != 0) {
		xmlAddChild(node, [self.activityLogDefinitionID xmlNodeForDoc:node->doc elementName:@"activityLogDefinitionID" elementNSPrefix:nil]);
	}
	if(self.activityLogDefinitionName != 0) {
		xmlAddChild(node, [self.activityLogDefinitionName xmlNodeForDoc:node->doc elementName:@"activityLogDefinitionName" elementNSPrefix:nil]);
	}
	if(self.activityLogDefinitionDesc != 0) {
		xmlAddChild(node, [self.activityLogDefinitionDesc xmlNodeForDoc:node->doc elementName:@"activityLogDefinitionDesc" elementNSPrefix:nil]);
	}
	if(self.value != 0) {
		xmlAddChild(node, [self.value xmlNodeForDoc:node->doc elementName:@"value" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize activityLogDefinitionID;
@synthesize activityLogDefinitionName;
@synthesize activityLogDefinitionDesc;
@synthesize value;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ActivityLogDetailItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ActivityLogDetailItem *newObject = [[LibreAccessActivityLogSvc_ActivityLogDetailItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogDefinitionID")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.activityLogDefinitionID = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogDefinitionName")) {
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
				
                    self.activityLogDefinitionName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogDefinitionDesc")) {
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
				
                    self.activityLogDefinitionDesc = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "value")) {
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
				
                    self.value = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_ActivityLogDetailList
- (id)init
{
	if((self = [super init])) {
		activityLogDetailItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(activityLogDetailItem != nil) [activityLogDetailItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityLogDetailItem != 0) {
		for(LibreAccessActivityLogSvc_ActivityLogDetailItem * child in self.activityLogDetailItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"activityLogDetailItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize activityLogDetailItem;
- (void)addActivityLogDetailItem:(LibreAccessActivityLogSvc_ActivityLogDetailItem *)toAdd
{
	if(toAdd != nil) [activityLogDetailItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ActivityLogDetailList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ActivityLogDetailList *newObject = [[LibreAccessActivityLogSvc_ActivityLogDetailList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogDetailItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_ActivityLogDetailItem class];
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
				
                    if(newChild != nil) [self.activityLogDetailItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ActivityLogFactItem
- (id)init
{
	if((self = [super init])) {
		activityLogFactID = 0;
		activityName = 0;
		userKey = 0;
		activityLogDetailList = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(activityLogFactID != nil) [activityLogFactID release];
	if(activityName != nil) [activityName release];
	if(userKey != nil) [userKey release];
	if(activityLogDetailList != nil) [activityLogDetailList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityLogFactID != 0) {
		xmlAddChild(node, [self.activityLogFactID xmlNodeForDoc:node->doc elementName:@"activityLogFactID" elementNSPrefix:nil]);
	}
	if(self.activityName != 0) {
		xmlAddChild(node, [self.activityName xmlNodeForDoc:node->doc elementName:@"activityName" elementNSPrefix:nil]);
	}
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.activityLogDetailList != 0) {
		xmlAddChild(node, [self.activityLogDetailList xmlNodeForDoc:node->doc elementName:@"activityLogDetailList" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize activityLogFactID;
@synthesize activityName;
@synthesize userKey;
@synthesize activityLogDetailList;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ActivityLogFactItem *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ActivityLogFactItem *newObject = [[LibreAccessActivityLogSvc_ActivityLogFactItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogFactID")) {
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
                        elementClass = [NSNumber class];
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
				
                    self.activityLogFactID = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityName")) {
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
				
                    self.activityName = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogDetailList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_ActivityLogDetailList class];
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
				
                    self.activityLogDetailList = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_ActivityLogFactList
- (id)init
{
	if((self = [super init])) {
		activityLogFactItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(activityLogFactItem != nil) [activityLogFactItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityLogFactItem != 0) {
		for(LibreAccessActivityLogSvc_ActivityLogFactItem * child in self.activityLogFactItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"activityLogFactItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize activityLogFactItem;
- (void)addActivityLogFactItem:(LibreAccessActivityLogSvc_ActivityLogFactItem *)toAdd
{
	if(toAdd != nil) [activityLogFactItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ActivityLogFactList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ActivityLogFactList *newObject = [[LibreAccessActivityLogSvc_ActivityLogFactList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogFactItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_ActivityLogFactItem class];
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
				
                    if(newChild != nil) [self.activityLogFactItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ListActivityLogResponse
- (id)init
{
	if((self = [super init])) {
		statusmessage = 0;
		activityLogFactList = 0;
		ItemsCount = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusmessage != nil) [statusmessage release];
	if(activityLogFactList != nil) [activityLogFactList release];
	if(ItemsCount != nil) [ItemsCount release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
	if(self.activityLogFactList != 0) {
		xmlAddChild(node, [self.activityLogFactList xmlNodeForDoc:node->doc elementName:@"activityLogFactList" elementNSPrefix:nil]);
	}
	if(self.ItemsCount != 0) {
		xmlAddChild(node, [self.ItemsCount xmlNodeForDoc:node->doc elementName:@"ItemsCount" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusmessage;
@synthesize activityLogFactList;
@synthesize ItemsCount;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListActivityLogResponse *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListActivityLogResponse *newObject = [[LibreAccessActivityLogSvc_ListActivityLogResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
                        elementClass = [LibreAccessActivityLogSvc_StatusHolder class];
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
				
                    self.statusmessage = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityLogFactList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_ActivityLogFactList class];
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
				
                    self.activityLogFactList = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "ItemsCount")) {
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
                        elementClass = [LibreAccessActivityLogSvc_ItemsCount class];
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
				
                    self.ItemsCount = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_ActivityMasterNameList
- (id)init
{
	if((self = [super init])) {
		activityMasterName = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(activityMasterName != nil) [activityMasterName release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.activityMasterName != 0) {
		for(NSString * child in self.activityMasterName) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"activityMasterName" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize activityMasterName;
- (void)addActivityMasterName:(NSString *)toAdd
{
	if(toAdd != nil) [activityMasterName addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ActivityMasterNameList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ActivityMasterNameList *newObject = [[LibreAccessActivityLogSvc_ActivityMasterNameList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityMasterName")) {
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
				
                    if(newChild != nil) [self.activityMasterName addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_UserKeysList
- (id)init
{
	if((self = [super init])) {
		userKey = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(userKey != nil) [userKey release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.userKey != 0) {
		for(NSString * child in self.userKey) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize userKey;
- (void)addUserKey:(NSString *)toAdd
{
	if(toAdd != nil) [userKey addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_UserKeysList *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_UserKeysList *newObject = [[LibreAccessActivityLogSvc_UserKeysList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    if(newChild != nil) [self.userKey addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ListAvailableDumps
- (id)init
{
	if((self = [super init])) {
		CSRtoken = 0;
		userKeysList = 0;
		minTimestamp = 0;
		maxTimestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(CSRtoken != nil) [CSRtoken release];
	if(userKeysList != nil) [userKeysList release];
	if(minTimestamp != nil) [minTimestamp release];
	if(maxTimestamp != nil) [maxTimestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.CSRtoken != 0) {
		xmlAddChild(node, [self.CSRtoken xmlNodeForDoc:node->doc elementName:@"CSRtoken" elementNSPrefix:nil]);
	}
	if(self.userKeysList != 0) {
		xmlAddChild(node, [self.userKeysList xmlNodeForDoc:node->doc elementName:@"userKeysList" elementNSPrefix:nil]);
	}
	if(self.minTimestamp != 0) {
		xmlAddChild(node, [self.minTimestamp xmlNodeForDoc:node->doc elementName:@"minTimestamp" elementNSPrefix:nil]);
	}
	if(self.maxTimestamp != 0) {
		xmlAddChild(node, [self.maxTimestamp xmlNodeForDoc:node->doc elementName:@"maxTimestamp" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize CSRtoken;
@synthesize userKeysList;
@synthesize minTimestamp;
@synthesize maxTimestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListAvailableDumps *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListAvailableDumps *newObject = [[LibreAccessActivityLogSvc_ListAvailableDumps new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "CSRtoken")) {
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
				
                    self.CSRtoken = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKeysList")) {
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
                        elementClass = [LibreAccessActivityLogSvc_UserKeysList class];
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
				
                    self.userKeysList = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "minTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.minTimestamp = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "maxTimestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.maxTimestamp = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_DumpItemAvailable
- (id)init
{
	if((self = [super init])) {
		userKey = 0;
		deviceKey = 0;
		timestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(userKey != nil) [userKey release];
	if(deviceKey != nil) [deviceKey release];
	if(timestamp != nil) [timestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.userKey != 0) {
		xmlAddChild(node, [self.userKey xmlNodeForDoc:node->doc elementName:@"userKey" elementNSPrefix:nil]);
	}
	if(self.deviceKey != 0) {
		xmlAddChild(node, [self.deviceKey xmlNodeForDoc:node->doc elementName:@"deviceKey" elementNSPrefix:nil]);
	}
	if(self.timestamp != 0) {
		xmlAddChild(node, [self.timestamp xmlNodeForDoc:node->doc elementName:@"timestamp" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize userKey;
@synthesize deviceKey;
@synthesize timestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_DumpItemAvailable *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_DumpItemAvailable *newObject = [[LibreAccessActivityLogSvc_DumpItemAvailable new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "userKey")) {
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
				
                    self.userKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "deviceKey")) {
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
				
                    self.deviceKey = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "timestamp")) {
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
                        elementClass = [NSDate class];
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
				
                    self.timestamp = newChild;
                }
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
@implementation LibreAccessActivityLogSvc_DumpListAvailable
- (id)init
{
	if((self = [super init])) {
		dumpItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(dumpItem != nil) [dumpItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.dumpItem != 0) {
		for(LibreAccessActivityLogSvc_DumpItemAvailable * child in self.dumpItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"dumpItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize dumpItem;
- (void)addDumpItem:(LibreAccessActivityLogSvc_DumpItemAvailable *)toAdd
{
	if(toAdd != nil) [dumpItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_DumpListAvailable *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_DumpListAvailable *newObject = [[LibreAccessActivityLogSvc_DumpListAvailable new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "dumpItem")) {
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
                        elementClass = [LibreAccessActivityLogSvc_DumpItemAvailable class];
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
				
                    if(newChild != nil) [self.dumpItem addObject:newChild];
                }
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
@implementation LibreAccessActivityLogSvc_ListAvailableDumpsResponse
- (id)init
{
	if((self = [super init])) {
		statusmessage = 0;
		dumpItems = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusmessage != nil) [statusmessage release];
	if(dumpItems != nil) [dumpItems release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"LibreAccessActivityLogSvc";
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
		nodeName = elName;
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
	
	if(self.statusmessage != 0) {
		xmlAddChild(node, [self.statusmessage xmlNodeForDoc:node->doc elementName:@"statusmessage" elementNSPrefix:nil]);
	}
	if(self.dumpItems != 0) {
		xmlAddChild(node, [self.dumpItems xmlNodeForDoc:node->doc elementName:@"dumpItems" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusmessage;
@synthesize dumpItems;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (LibreAccessActivityLogSvc_ListAvailableDumpsResponse *)deserializeNode:(xmlNodePtr)cur
{
	LibreAccessActivityLogSvc_ListAvailableDumpsResponse *newObject = [[LibreAccessActivityLogSvc_ListAvailableDumpsResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusmessage")) {
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
                        elementClass = [LibreAccessActivityLogSvc_StatusHolder class];
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
				
                    self.statusmessage = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "dumpItems")) {
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
                        elementClass = [LibreAccessActivityLogSvc_DumpListAvailable class];
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
				
                    self.dumpItems = newChild;
                }
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
@implementation LibreAccessActivityLogSvc
+ (void)initialize
{
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"xsd" forKey:@"http://www.w3.org/2001/XMLSchema"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"LibreAccessActivityLogSvc" forKey:@"http://webservices.libredigital.com/LibreAccess/2010-02-10"];
}
+ (LibreAccessActivityLogOldSoap11Binding *)LibreAccessActivityLogOldSoap11Binding
{
	return [[[LibreAccessActivityLogOldSoap11Binding alloc] initWithAddress:@"http://laesb.dev.cld.libredigital.com/services/LibreAccessActivityLogOld.LibreAccessActivityLogOldHttpSoap11Endpoint"] autorelease];
}
@end
@implementation LibreAccessActivityLogOldSoap11Binding
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
- (LibreAccessActivityLogOldSoap11BindingResponse *)performSynchronousOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation
{
	synchronousOperationComplete = NO;
	[operation start];
	
	// Now wait for response
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	
	while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	return operation.response;
}
- (void)performAsynchronousOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation
{
	[operation start];
}
- (void) operation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation completedWithResponse:(LibreAccessActivityLogOldSoap11BindingResponse *)response
{
	synchronousOperationComplete = YES;
}
- (LibreAccessActivityLogOldSoap11BindingResponse *)SaveActivityLogUsingParameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessActivityLogOldSoap11Binding_SaveActivityLog*)[LibreAccessActivityLogOldSoap11Binding_SaveActivityLog alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveActivityLogAsyncUsingParameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessActivityLogOldSoap11Binding_SaveActivityLog*)[LibreAccessActivityLogOldSoap11Binding_SaveActivityLog alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessActivityLogOldSoap11BindingResponse *)SaveDumpUsingParameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessActivityLogOldSoap11Binding_SaveDump*)[LibreAccessActivityLogOldSoap11Binding_SaveDump alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)SaveDumpAsyncUsingParameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessActivityLogOldSoap11Binding_SaveDump*)[LibreAccessActivityLogOldSoap11Binding_SaveDump alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListActivityLogUsingParameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessActivityLogOldSoap11Binding_ListActivityLog*)[LibreAccessActivityLogOldSoap11Binding_ListActivityLog alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListActivityLogAsyncUsingParameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessActivityLogOldSoap11Binding_ListActivityLog*)[LibreAccessActivityLogOldSoap11Binding_ListActivityLog alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListDumpUsingParameters:(LibreAccessActivityLogSvc_ListDump *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessActivityLogOldSoap11Binding_ListDump*)[LibreAccessActivityLogOldSoap11Binding_ListDump alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListDumpAsyncUsingParameters:(LibreAccessActivityLogSvc_ListDump *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessActivityLogOldSoap11Binding_ListDump*)[LibreAccessActivityLogOldSoap11Binding_ListDump alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (LibreAccessActivityLogOldSoap11BindingResponse *)ListAvailableDumpsUsingParameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters 
{
	return [self performSynchronousOperation:[[(LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps*)[LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)ListAvailableDumpsAsyncUsingParameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters  delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps*)[LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (void)sendHTTPCallUsingBody:(NSString *)outputBody soapAction:(NSString *)soapAction forOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation
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
- (void) addPointerForOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation
{
    NSValue *pointerValue = [NSValue valueWithNonretainedObject:operation];
    [self.operationPointers addObject:pointerValue];
}
- (void) removePointerForOperation:(LibreAccessActivityLogOldSoap11BindingOperation *)operation
{
    NSIndexSet *matches = [self.operationPointers indexesOfObjectsPassingTest:^BOOL (id el, NSUInteger i, BOOL *stop) {
                               LibreAccessActivityLogOldSoap11BindingOperation *op = [el nonretainedObjectValue];
                               return [op isEqual:operation];
                           }];
    [self.operationPointers removeObjectsAtIndexes:matches];
}
- (void) clearBindingOperations
{
    for (NSValue *pointerValue in self.operationPointers) {
        LibreAccessActivityLogOldSoap11BindingOperation *operation = [pointerValue nonretainedObjectValue];
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
@implementation LibreAccessActivityLogOldSoap11BindingOperation
@synthesize binding;
@synthesize response;
@synthesize delegate;
@synthesize responseHeaders;
@synthesize responseData;
@synthesize serverDateDelta;
@synthesize urlConnection;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)aDelegate
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
				
			error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 												[NSString stringWithFormat: @"Unexpected response MIME type to SOAP call:%@", urlResponse.MIMEType],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
			error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseHTTP" code:1 userInfo:userInfo];
		}
				
		[self connection:connection didFailWithError:error];
	} else if ([httpResponse statusCode] >= 400) {
		NSError *error = nil;
		[connection cancel];	
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]],NSLocalizedDescriptionKey,
                                                                         httpResponse.URL, NSURLErrorKey, nil];
				
		error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
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
@implementation LibreAccessActivityLogOldSoap11Binding_SaveActivityLog
@synthesize parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
parameters:(LibreAccessActivityLogSvc_SaveActivityLog *)aParameters
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
	response = [LibreAccessActivityLogOldSoap11BindingResponse new];
	
	LibreAccessActivityLogOldSoap11Binding_envelope *envelope = [LibreAccessActivityLogOldSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"SaveActivityLog"];
		[bodyKeys addObject:@"SaveActivityLog"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveActivityLog" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveActivityLogResponse")) {
										LibreAccessActivityLogSvc_SaveActivityLogResponse *bodyObject = [LibreAccessActivityLogSvc_SaveActivityLogResponse deserializeNode:bodyNode];
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
@implementation LibreAccessActivityLogOldSoap11Binding_SaveDump
@synthesize parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
parameters:(LibreAccessActivityLogSvc_SaveDump *)aParameters
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
	response = [LibreAccessActivityLogOldSoap11BindingResponse new];
	
	LibreAccessActivityLogOldSoap11Binding_envelope *envelope = [LibreAccessActivityLogOldSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"SaveDump"];
		[bodyKeys addObject:@"SaveDump"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/SaveDump" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "SaveDumpResponse")) {
										LibreAccessActivityLogSvc_SaveDumpResponse *bodyObject = [LibreAccessActivityLogSvc_SaveDumpResponse deserializeNode:bodyNode];
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
@implementation LibreAccessActivityLogOldSoap11Binding_ListActivityLog
@synthesize parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
parameters:(LibreAccessActivityLogSvc_ListActivityLog *)aParameters
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
	response = [LibreAccessActivityLogOldSoap11BindingResponse new];
	
	LibreAccessActivityLogOldSoap11Binding_envelope *envelope = [LibreAccessActivityLogOldSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"ListActivityLog"];
		[bodyKeys addObject:@"ListActivityLog"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListActivityLog" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListActivityLogResponse")) {
										LibreAccessActivityLogSvc_ListActivityLogResponse *bodyObject = [LibreAccessActivityLogSvc_ListActivityLogResponse deserializeNode:bodyNode];
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
@implementation LibreAccessActivityLogOldSoap11Binding_ListDump
@synthesize parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
parameters:(LibreAccessActivityLogSvc_ListDump *)aParameters
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
	response = [LibreAccessActivityLogOldSoap11BindingResponse new];
	
	LibreAccessActivityLogOldSoap11Binding_envelope *envelope = [LibreAccessActivityLogOldSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"ListDump"];
		[bodyKeys addObject:@"ListDump"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListDump" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListDumpResponse")) {
										LibreAccessActivityLogSvc_ListDumpResponse *bodyObject = [LibreAccessActivityLogSvc_ListDumpResponse deserializeNode:bodyNode];
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
@implementation LibreAccessActivityLogOldSoap11Binding_ListAvailableDumps
@synthesize parameters;
- (id)initWithBinding:(LibreAccessActivityLogOldSoap11Binding *)aBinding delegate:(id<LibreAccessActivityLogOldSoap11BindingResponseDelegate>)responseDelegate
parameters:(LibreAccessActivityLogSvc_ListAvailableDumps *)aParameters
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
	response = [LibreAccessActivityLogOldSoap11BindingResponse new];
	
	LibreAccessActivityLogOldSoap11Binding_envelope *envelope = [LibreAccessActivityLogOldSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"ListAvailableDumps"];
		[bodyKeys addObject:@"ListAvailableDumps"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"http://webservices.libredigital.com/libreaccess/ListAvailableDumps" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"LibreAccessActivityLogOldSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "ListAvailableDumpsResponse")) {
										LibreAccessActivityLogSvc_ListAvailableDumpsResponse *bodyObject = [LibreAccessActivityLogSvc_ListAvailableDumpsResponse deserializeNode:bodyNode];
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
static LibreAccessActivityLogOldSoap11Binding_envelope *LibreAccessActivityLogOldSoap11BindingSharedEnvelopeInstance = nil;
@implementation LibreAccessActivityLogOldSoap11Binding_envelope
+ (LibreAccessActivityLogOldSoap11Binding_envelope *)sharedInstance
{
	if(LibreAccessActivityLogOldSoap11BindingSharedEnvelopeInstance == nil) {
		LibreAccessActivityLogOldSoap11BindingSharedEnvelopeInstance = [LibreAccessActivityLogOldSoap11Binding_envelope new];
	}
	
	return LibreAccessActivityLogOldSoap11BindingSharedEnvelopeInstance;
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
	xmlNewNs(root, (const xmlChar*)"http://webservices.libredigital.com/LibreAccess/2010-02-10", (const xmlChar*)"LibreAccessActivityLogSvc");
	
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
			xmlAddChild(bodyNode, [body xmlNodeForDoc:doc elementName:key elementNSPrefix:[body nsPrefix]]);
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
@implementation LibreAccessActivityLogOldSoap11BindingResponse
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
