// Version 1.7.5.0

#import "LibreAccessActivityLogSvc_tns1.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
tns1_StatusCodes tns1_StatusCodes_enumFromString(NSString *string)
{
	if([string isEqualToString:@"SUCCESS"]) {
		return tns1_StatusCodes_SUCCESS;
	}
	if([string isEqualToString:@"FAIL"]) {
		return tns1_StatusCodes_FAIL;
	}
	
	return tns1_StatusCodes_none;
}
NSString * tns1_StatusCodes_stringFromEnum(tns1_StatusCodes enumValue)
{
	switch (enumValue) {
		case tns1_StatusCodes_SUCCESS:
			return @"SUCCESS";
			break;
		case tns1_StatusCodes_FAIL:
			return @"FAIL";
			break;
		default:
			return @"";
	}
}
@implementation tns1_StatusHolder2
- (id)init
{
	if((self = [super init])) {
		status = 0;
		statusCode = 0;
		statusMessage = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusCode != nil) [statusCode release];
	if(statusMessage != nil) [statusMessage release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"tns1";
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
		xmlNewChild(node, NULL, (const xmlChar*)"status", [tns1_StatusCodes_stringFromEnum(self.status) xmlString]);
	}
	if(self.statusCode != 0) {
		xmlAddChild(node, [self.statusCode xmlNodeForDoc:node->doc elementName:@"statusCode" elementNSPrefix:nil]);
	}
	if(self.statusMessage != 0) {
		xmlAddChild(node, [self.statusMessage xmlNodeForDoc:node->doc elementName:@"statusMessage" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize status;
@synthesize statusCode;
@synthesize statusMessage;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_StatusHolder2 *)deserializeNode:(xmlNodePtr)cur
{
	tns1_StatusHolder2 *newObject = [[tns1_StatusHolder2 new] autorelease];
	
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
				
				tns1_StatusCodes enumRepresentation = tns1_StatusCodes_enumFromString(elementString);
				self.status = enumRepresentation;
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusCode")) {
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
				
                    self.statusCode = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusMessage")) {
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
				
                    self.statusMessage = newChild;
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
@implementation tns1_LogItem
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
	return @"tns1";
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
+ (tns1_LogItem *)deserializeNode:(xmlNodePtr)cur
{
	tns1_LogItem *newObject = [[tns1_LogItem new] autorelease];
	
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
@implementation tns1_LogsList
- (id)init
{
	if((self = [super init])) {
		activityName = 0;
		correlationId = 0;
		logItem = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(activityName != nil) [activityName release];
	if(correlationId != nil) [correlationId release];
	if(logItem != nil) [logItem release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"tns1";
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
	if(self.correlationId != 0) {
		xmlAddChild(node, [self.correlationId xmlNodeForDoc:node->doc elementName:@"correlationId" elementNSPrefix:nil]);
	}
	if(self.logItem != 0) {
		for(tns1_LogItem * child in self.logItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"logItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize activityName;
@synthesize correlationId;
@synthesize logItem;
- (void)addLogItem:(tns1_LogItem *)toAdd
{
	if(toAdd != nil) [logItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_LogsList *)deserializeNode:(xmlNodePtr)cur
{
	tns1_LogsList *newObject = [[tns1_LogsList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "correlationId")) {
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
				
                    self.correlationId = newChild;
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
                        elementClass = [tns1_LogItem class];
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
@implementation tns1_SavedItem
- (id)init
{
	if((self = [super init])) {
		correlationId = 0;
		activityFactId = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(correlationId != nil) [correlationId release];
	if(activityFactId != nil) [activityFactId release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"tns1";
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
	
	if(self.correlationId != 0) {
		xmlAddChild(node, [self.correlationId xmlNodeForDoc:node->doc elementName:@"correlationId" elementNSPrefix:nil]);
	}
	if(self.activityFactId != 0) {
		xmlAddChild(node, [self.activityFactId xmlNodeForDoc:node->doc elementName:@"activityFactId" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize correlationId;
@synthesize activityFactId;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_SavedItem *)deserializeNode:(xmlNodePtr)cur
{
	tns1_SavedItem *newObject = [[tns1_SavedItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "correlationId")) {
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
				
                    self.correlationId = newChild;
                }
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "activityFactId")) {
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
				
                    self.activityFactId = newChild;
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
@implementation tns1_SavedIdsList
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
	return @"tns1";
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
		for(tns1_SavedItem * child in self.savedItem) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"savedItem" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize savedItem;
- (void)addSavedItem:(tns1_SavedItem *)toAdd
{
	if(toAdd != nil) [savedItem addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_SavedIdsList *)deserializeNode:(xmlNodePtr)cur
{
	tns1_SavedIdsList *newObject = [[tns1_SavedIdsList new] autorelease];
	
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
                        elementClass = [tns1_SavedItem class];
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
@implementation tns1_SaveActivityLogRequest
- (id)init
{
	if((self = [super init])) {
		authToken = 0;
		userKey = 0;
		creationDate = 0;
		logsList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(authToken != nil) [authToken release];
	if(userKey != nil) [userKey release];
	if(creationDate != nil) [creationDate release];
	if(logsList != nil) [logsList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"tns1";
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
	if(self.creationDate != 0) {
		xmlAddChild(node, [self.creationDate xmlNodeForDoc:node->doc elementName:@"creationDate" elementNSPrefix:nil]);
	}
	if(self.logsList != 0) {
		for(tns1_LogsList * child in self.logsList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"logsList" elementNSPrefix:nil]);
		}
	}
}
/* elements */
@synthesize authToken;
@synthesize userKey;
@synthesize creationDate;
@synthesize logsList;
- (void)addLogsList:(tns1_LogsList *)toAdd
{
	if(toAdd != nil) [logsList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_SaveActivityLogRequest *)deserializeNode:(xmlNodePtr)cur
{
	tns1_SaveActivityLogRequest *newObject = [[tns1_SaveActivityLogRequest new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "creationDate")) {
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
				
                    self.creationDate = newChild;
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
                        elementClass = [tns1_LogsList class];
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
@implementation tns1_SaveActivityLogResponse
- (id)init
{
	if((self = [super init])) {
		statusMessage = 0;
		savedIdsList = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(statusMessage != nil) [statusMessage release];
	if(savedIdsList != nil) [savedIdsList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"tns1";
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
	
	if(self.statusMessage != 0) {
		xmlAddChild(node, [self.statusMessage xmlNodeForDoc:node->doc elementName:@"statusMessage" elementNSPrefix:nil]);
	}
	if(self.savedIdsList != 0) {
		xmlAddChild(node, [self.savedIdsList xmlNodeForDoc:node->doc elementName:@"savedIdsList" elementNSPrefix:nil]);
	}
}
/* elements */
@synthesize statusMessage;
@synthesize savedIdsList;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (tns1_SaveActivityLogResponse *)deserializeNode:(xmlNodePtr)cur
{
	tns1_SaveActivityLogResponse *newObject = [[tns1_SaveActivityLogResponse new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "statusMessage")) {
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
                        elementClass = [tns1_StatusHolder2 class];
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
				
                    self.statusMessage = newChild;
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
                        elementClass = [tns1_SavedIdsList class];
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
