#import "WishListServiceSvc.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
@implementation WishListServiceSvc_DeleteWishListItems
- (id)init
{
	if((self = [super init])) {
		clientID = 0;
		token = 0;
		spsIdParam = 0;
		profileItemList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(clientID != nil) [clientID release];
	if(token != nil) [token release];
	if(spsIdParam != nil) [spsIdParam release];
	if(profileItemList != nil) [profileItemList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
	
	if(self.clientID != 0) {
		xmlAddChild(node, [self.clientID xmlNodeForDoc:node->doc elementName:@"clientID" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.token != 0) {
		xmlAddChild(node, [self.token xmlNodeForDoc:node->doc elementName:@"token" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.spsIdParam != 0) {
		xmlAddChild(node, [self.spsIdParam xmlNodeForDoc:node->doc elementName:@"spsIdParam" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.profileItemList != 0) {
		for(ax21_WishListProfileItem * child in self.profileItemList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileItemList" elementNSPrefix:@"WishListServiceSvc"]);
		}
	}
}
/* elements */
@synthesize clientID;
@synthesize token;
@synthesize spsIdParam;
@synthesize profileItemList;
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd
{
	if(toAdd != nil) [profileItemList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (WishListServiceSvc_DeleteWishListItems *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_DeleteWishListItems *newObject = [[WishListServiceSvc_DeleteWishListItems new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "clientID")) {
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
				
					self.clientID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "token")) {
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
				
					self.token = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsIdParam")) {
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
				
					self.spsIdParam = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileItemList")) {
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
						elementClass = [ax21_WishListProfileItem class];
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
				
					if(nilProperty == NO && newChild != nil) [self.profileItemList addObject:newChild];
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_DeleteWishListItemsResponse
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
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"WishListServiceSvc"]);
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
+ (WishListServiceSvc_DeleteWishListItemsResponse *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_DeleteWishListItemsResponse *newObject = [[WishListServiceSvc_DeleteWishListItemsResponse new] autorelease];
	
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
						elementClass = [ax21_WishListStatus class];
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
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_AddItemsToWishList
- (id)init
{
	if((self = [super init])) {
		clientID = 0;
		token = 0;
		spsIdParam = 0;
		profileItemList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(clientID != nil) [clientID release];
	if(token != nil) [token release];
	if(spsIdParam != nil) [spsIdParam release];
	if(profileItemList != nil) [profileItemList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
	
	if(self.clientID != 0) {
		xmlAddChild(node, [self.clientID xmlNodeForDoc:node->doc elementName:@"clientID" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.token != 0) {
		xmlAddChild(node, [self.token xmlNodeForDoc:node->doc elementName:@"token" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.spsIdParam != 0) {
		xmlAddChild(node, [self.spsIdParam xmlNodeForDoc:node->doc elementName:@"spsIdParam" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.profileItemList != 0) {
		for(ax21_WishListProfileItem * child in self.profileItemList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileItemList" elementNSPrefix:@"WishListServiceSvc"]);
		}
	}
}
/* elements */
@synthesize clientID;
@synthesize token;
@synthesize spsIdParam;
@synthesize profileItemList;
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd
{
	if(toAdd != nil) [profileItemList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (WishListServiceSvc_AddItemsToWishList *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_AddItemsToWishList *newObject = [[WishListServiceSvc_AddItemsToWishList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "clientID")) {
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
				
					self.clientID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "token")) {
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
				
					self.token = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsIdParam")) {
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
				
					self.spsIdParam = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileItemList")) {
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
						elementClass = [ax21_WishListProfileItem class];
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
				
					if(nilProperty == NO && newChild != nil) [self.profileItemList addObject:newChild];
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_AddItemsToWishListResponse
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
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"WishListServiceSvc"]);
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
+ (WishListServiceSvc_AddItemsToWishListResponse *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_AddItemsToWishListResponse *newObject = [[WishListServiceSvc_AddItemsToWishListResponse new] autorelease];
	
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
						elementClass = [ax21_WishListStatus class];
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
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_GetWishListItems
- (id)init
{
	if((self = [super init])) {
		clientID = 0;
		token = 0;
		spsIdParam = 0;
		profileIdList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(clientID != nil) [clientID release];
	if(token != nil) [token release];
	if(spsIdParam != nil) [spsIdParam release];
	if(profileIdList != nil) [profileIdList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
	
	if(self.clientID != 0) {
		xmlAddChild(node, [self.clientID xmlNodeForDoc:node->doc elementName:@"clientID" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.token != 0) {
		xmlAddChild(node, [self.token xmlNodeForDoc:node->doc elementName:@"token" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.spsIdParam != 0) {
		xmlAddChild(node, [self.spsIdParam xmlNodeForDoc:node->doc elementName:@"spsIdParam" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.profileIdList != 0) {
		for(NSNumber * child in self.profileIdList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileIdList" elementNSPrefix:@"WishListServiceSvc"]);
		}
	}
}
/* elements */
@synthesize clientID;
@synthesize token;
@synthesize spsIdParam;
@synthesize profileIdList;
- (void)addProfileIdList:(NSNumber *)toAdd
{
	if(toAdd != nil) [profileIdList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (WishListServiceSvc_GetWishListItems *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_GetWishListItems *newObject = [[WishListServiceSvc_GetWishListItems new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "clientID")) {
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
				
					self.clientID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "token")) {
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
				
					self.token = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsIdParam")) {
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
				
					self.spsIdParam = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileIdList")) {
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
				
					if(nilProperty == NO && newChild != nil) [self.profileIdList addObject:newChild];
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_GetWishListItemsResponse
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
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"WishListServiceSvc"]);
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
+ (WishListServiceSvc_GetWishListItemsResponse *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_GetWishListItemsResponse *newObject = [[WishListServiceSvc_GetWishListItemsResponse new] autorelease];
	
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
						elementClass = [ax21_WishList class];
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
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_DeleteWishList
- (id)init
{
	if((self = [super init])) {
		clientID = 0;
		token = 0;
		spsIdParam = 0;
		profileIdList = [[NSMutableArray alloc] init];
	}
	
	return self;
}
- (void)dealloc
{
	if(clientID != nil) [clientID release];
	if(token != nil) [token release];
	if(spsIdParam != nil) [spsIdParam release];
	if(profileIdList != nil) [profileIdList release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
	
	if(self.clientID != 0) {
		xmlAddChild(node, [self.clientID xmlNodeForDoc:node->doc elementName:@"clientID" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.token != 0) {
		xmlAddChild(node, [self.token xmlNodeForDoc:node->doc elementName:@"token" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.spsIdParam != 0) {
		xmlAddChild(node, [self.spsIdParam xmlNodeForDoc:node->doc elementName:@"spsIdParam" elementNSPrefix:@"WishListServiceSvc"]);
	}
	if(self.profileIdList != 0) {
		for(ax21_WishListProfile * child in self.profileIdList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileIdList" elementNSPrefix:@"WishListServiceSvc"]);
		}
	}
}
/* elements */
@synthesize clientID;
@synthesize token;
@synthesize spsIdParam;
@synthesize profileIdList;
- (void)addProfileIdList:(ax21_WishListProfile *)toAdd
{
	if(toAdd != nil) [profileIdList addObject:toAdd];
}
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (WishListServiceSvc_DeleteWishList *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_DeleteWishList *newObject = [[WishListServiceSvc_DeleteWishList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "clientID")) {
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
				
					self.clientID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "token")) {
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
				
					self.token = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsIdParam")) {
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
				
					self.spsIdParam = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileIdList")) {
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
						elementClass = [ax21_WishListProfile class];
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
				
					if(nilProperty == NO && newChild != nil) [self.profileIdList addObject:newChild];
				}
			}
		}
	}
}
/* NSCoder functions taken from: 
 * http://davedelong.com/blog/2009/04/13/aspect-oriented-programming-objective-c
 */
- (id) initWithCoder:(NSCoder *)decoder {
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc_DeleteWishListResponse
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
	return @"WishListServiceSvc";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"WishListServiceSvc", elName];
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
		xmlAddChild(node, [self.return_ xmlNodeForDoc:node->doc elementName:@"return" elementNSPrefix:@"WishListServiceSvc"]);
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
+ (WishListServiceSvc_DeleteWishListResponse *)deserializeNode:(xmlNodePtr)cur
{
	WishListServiceSvc_DeleteWishListResponse *newObject = [[WishListServiceSvc_DeleteWishListResponse new] autorelease];
	
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
						elementClass = [ax21_WishListStatus class];
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
	if ([super respondsToSelector:@selector(initWithCoder:)] && ![self isKindOfClass:[super class]]) {
		self = [(id)super initWithCoder:decoder];
	} else {
		self = [super init];
	}
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
@implementation WishListServiceSvc
+ (void)initialize
{
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"xsd" forKey:@"http://www.w3.org/2001/XMLSchema"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"WishListServiceSvc" forKey:@"http://services.ebooks.schws.scholastic.com"];
	[[USGlobals sharedInstance].wsdlStandardNamespaces setObject:@"ax21" forKey:@"http://beans.ebooks.schws.scholastic.com/xsd"];
}
+ (WishListServiceSoap11Binding *)WishListServiceSoap11Binding
{
    NSLog(@"SOAP WishList using: %@", WISHLIST_SERVER_ENDPOINT);
    return [[[WishListServiceSoap11Binding alloc] initWithAddress:WISHLIST_SERVER_ENDPOINT] autorelease];
}
@end
@implementation WishListServiceSoap11Binding
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
- (WishListServiceSoap11BindingResponse *)performSynchronousOperation:(WishListServiceSoap11BindingOperation *)operation
{
	synchronousOperationComplete = NO;
	[operation start];
	
	// Now wait for response
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	
	while (!synchronousOperationComplete && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	return operation.response;
}
- (void)performAsynchronousOperation:(WishListServiceSoap11BindingOperation *)operation
{
	[operation start];
}
- (void) operation:(WishListServiceSoap11BindingOperation *)operation completedWithResponse:(WishListServiceSoap11BindingResponse *)response
{
	synchronousOperationComplete = YES;
}
- (WishListServiceSoap11BindingResponse *)DeleteWishListUsingParameters:(WishListServiceSvc_DeleteWishList *)aParameters 
{
	return [self performSynchronousOperation:[[(WishListServiceSoap11Binding_DeleteWishList*)[WishListServiceSoap11Binding_DeleteWishList alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeleteWishListAsyncUsingParameters:(WishListServiceSvc_DeleteWishList *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(WishListServiceSoap11Binding_DeleteWishList*)[WishListServiceSoap11Binding_DeleteWishList alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (WishListServiceSoap11BindingResponse *)DeleteWishListItemsUsingParameters:(WishListServiceSvc_DeleteWishListItems *)aParameters 
{
	return [self performSynchronousOperation:[[(WishListServiceSoap11Binding_DeleteWishListItems*)[WishListServiceSoap11Binding_DeleteWishListItems alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)DeleteWishListItemsAsyncUsingParameters:(WishListServiceSvc_DeleteWishListItems *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(WishListServiceSoap11Binding_DeleteWishListItems*)[WishListServiceSoap11Binding_DeleteWishListItems alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (WishListServiceSoap11BindingResponse *)AddItemsToWishListUsingParameters:(WishListServiceSvc_AddItemsToWishList *)aParameters 
{
	return [self performSynchronousOperation:[[(WishListServiceSoap11Binding_AddItemsToWishList*)[WishListServiceSoap11Binding_AddItemsToWishList alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)AddItemsToWishListAsyncUsingParameters:(WishListServiceSvc_AddItemsToWishList *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(WishListServiceSoap11Binding_AddItemsToWishList*)[WishListServiceSoap11Binding_AddItemsToWishList alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (WishListServiceSoap11BindingResponse *)GetWishListItemsUsingParameters:(WishListServiceSvc_GetWishListItems *)aParameters 
{
	return [self performSynchronousOperation:[[(WishListServiceSoap11Binding_GetWishListItems*)[WishListServiceSoap11Binding_GetWishListItems alloc] initWithBinding:self delegate:self
																							parameters:aParameters
																							] autorelease]];
}
- (void)GetWishListItemsAsyncUsingParameters:(WishListServiceSvc_GetWishListItems *)aParameters  delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
{
	[self performAsynchronousOperation: [[(WishListServiceSoap11Binding_GetWishListItems*)[WishListServiceSoap11Binding_GetWishListItems alloc] initWithBinding:self delegate:responseDelegate
																							 parameters:aParameters
																							 ] autorelease]];
}
- (void)sendHTTPCallUsingBody:(NSString *)outputBody soapAction:(NSString *)soapAction forOperation:(WishListServiceSoap11BindingOperation *)operation
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
- (void) addPointerForOperation:(WishListServiceSoap11BindingOperation *)operation
{
    NSValue *pointerValue = [NSValue valueWithNonretainedObject:operation];
    [self.operationPointers addObject:pointerValue];
}
- (void) removePointerForOperation:(WishListServiceSoap11BindingOperation *)operation
{
    NSIndexSet *matches = [self.operationPointers indexesOfObjectsPassingTest:^BOOL (id el, NSUInteger i, BOOL *stop) {
                               WishListServiceSoap11BindingOperation *op = [el nonretainedObjectValue];
                               return [op isEqual:operation];
                           }];
    [self.operationPointers removeObjectsAtIndexes:matches];
}
- (void) clearBindingOperations
{
    for (NSValue *pointerValue in self.operationPointers) {
        WishListServiceSoap11BindingOperation *operation = [pointerValue nonretainedObjectValue];
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
@implementation WishListServiceSoap11BindingOperation
@synthesize binding;
@synthesize response;
@synthesize delegate;
@synthesize responseHeaders;
@synthesize responseData;
@synthesize serverDateDelta;
@synthesize urlConnection;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)aDelegate
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
				
			error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseHTTP" code:[httpResponse statusCode] userInfo:userInfo];
		} else {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	 												[NSString stringWithFormat: @"Unexpected response MIME type to SOAP call:%@", urlResponse.MIMEType],NSLocalizedDescriptionKey,
                                                                          httpResponse.URL, NSURLErrorKey,nil];
			error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseHTTP" code:1 userInfo:userInfo];
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
@implementation WishListServiceSoap11Binding_DeleteWishList
@synthesize parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
parameters:(WishListServiceSvc_DeleteWishList *)aParameters
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
	response = [WishListServiceSoap11BindingResponse new];
	
	WishListServiceSoap11Binding_envelope *envelope = [WishListServiceSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"DeleteWishList"];
		[bodyKeys addObject:@"DeleteWishList"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:DeleteWishList" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeleteWishListResponse")) {
										WishListServiceSvc_DeleteWishListResponse *bodyObject = [WishListServiceSvc_DeleteWishListResponse deserializeNode:bodyNode];
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
@implementation WishListServiceSoap11Binding_DeleteWishListItems
@synthesize parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
parameters:(WishListServiceSvc_DeleteWishListItems *)aParameters
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
	response = [WishListServiceSoap11BindingResponse new];
	
	WishListServiceSoap11Binding_envelope *envelope = [WishListServiceSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"DeleteWishListItems"];
		[bodyKeys addObject:@"DeleteWishListItems"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:DeleteWishListItems" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "DeleteWishListItemsResponse")) {
										WishListServiceSvc_DeleteWishListItemsResponse *bodyObject = [WishListServiceSvc_DeleteWishListItemsResponse deserializeNode:bodyNode];
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
@implementation WishListServiceSoap11Binding_AddItemsToWishList
@synthesize parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
parameters:(WishListServiceSvc_AddItemsToWishList *)aParameters
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
	response = [WishListServiceSoap11BindingResponse new];
	
	WishListServiceSoap11Binding_envelope *envelope = [WishListServiceSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"AddItemsToWishList"];
		[bodyKeys addObject:@"AddItemsToWishList"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:AddItemsToWishList" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "AddItemsToWishListResponse")) {
										WishListServiceSvc_AddItemsToWishListResponse *bodyObject = [WishListServiceSvc_AddItemsToWishListResponse deserializeNode:bodyNode];
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
@implementation WishListServiceSoap11Binding_GetWishListItems
@synthesize parameters;
- (id)initWithBinding:(WishListServiceSoap11Binding *)aBinding delegate:(id<WishListServiceSoap11BindingResponseDelegate>)responseDelegate
parameters:(WishListServiceSvc_GetWishListItems *)aParameters
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
	response = [WishListServiceSoap11BindingResponse new];
	
	WishListServiceSoap11Binding_envelope *envelope = [WishListServiceSoap11Binding_envelope sharedInstance];
	
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
		[bodyElements setObject:obj forKey:@"GetWishListItems"];
		[bodyKeys addObject:@"GetWishListItems"];
	}
	
	NSString *operationXMLString = [envelope serializedFormUsingHeaderElements:headerElements bodyElements:bodyElements bodyKeys:bodyKeys];
	
	[binding sendHTTPCallUsingBody:operationXMLString soapAction:@"urn:GetWishListItems" forOperation:self];
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
			
				response.error = [NSError errorWithDomain:@"WishListServiceSoap11BindingResponseXML" code:1 userInfo:userInfo];
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
									if(xmlStrEqual(bodyNode->name, (const xmlChar *) "GetWishListItemsResponse")) {
										WishListServiceSvc_GetWishListItemsResponse *bodyObject = [WishListServiceSvc_GetWishListItemsResponse deserializeNode:bodyNode];
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
static WishListServiceSoap11Binding_envelope *WishListServiceSoap11BindingSharedEnvelopeInstance = nil;
@implementation WishListServiceSoap11Binding_envelope
+ (WishListServiceSoap11Binding_envelope *)sharedInstance
{
	if(WishListServiceSoap11BindingSharedEnvelopeInstance == nil) {
		WishListServiceSoap11BindingSharedEnvelopeInstance = [WishListServiceSoap11Binding_envelope new];
	}
	
	return WishListServiceSoap11BindingSharedEnvelopeInstance;
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
	xmlNewNs(root, (const xmlChar*)"http://services.ebooks.schws.scholastic.com", (const xmlChar*)"WishListServiceSvc");
	xmlNewNs(root, (const xmlChar*)"http://beans.ebooks.schws.scholastic.com/xsd", (const xmlChar*)"ax21");
	
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
@implementation WishListServiceSoap11BindingResponse
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
