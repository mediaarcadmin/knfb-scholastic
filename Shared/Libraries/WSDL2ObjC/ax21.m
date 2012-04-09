#import "ax21.h"
#import <libxml/xmlstring.h>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif
@implementation ax21_InitiatedByEnum
- (id)init
{
	if((self = [super init])) {
		value = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(value != nil) [value release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.value != 0) {
		xmlAddChild(node, [self.value xmlNodeForDoc:node->doc elementName:@"value" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:value" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"value" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize value;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_InitiatedByEnum *)deserializeNode:(xmlNodePtr)cur
{
	ax21_InitiatedByEnum *newObject = [[ax21_InitiatedByEnum new] autorelease];
	
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
@implementation ax21_WishListItem
- (id)init
{
	if((self = [super init])) {
		author = 0;
		initiatedBy = 0;
		isbn = 0;
		timeStamp = 0;
		title = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(author != nil) [author release];
	if(initiatedBy != nil) [initiatedBy release];
	if(isbn != nil) [isbn release];
	if(timeStamp != nil) [timeStamp release];
	if(title != nil) [title release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.author != 0) {
		xmlAddChild(node, [self.author xmlNodeForDoc:node->doc elementName:@"author" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:author" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"author" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.initiatedBy != 0) {
		xmlAddChild(node, [self.initiatedBy xmlNodeForDoc:node->doc elementName:@"initiatedBy" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:initiatedBy" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"initiatedBy" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.isbn != 0) {
		xmlAddChild(node, [self.isbn xmlNodeForDoc:node->doc elementName:@"isbn" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:isbn" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"isbn" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.timeStamp != 0) {
		xmlAddChild(node, [self.timeStamp xmlNodeForDoc:node->doc elementName:@"timeStamp" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:timeStamp" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"timeStamp" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.title != 0) {
		xmlAddChild(node, [self.title xmlNodeForDoc:node->doc elementName:@"title" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:title" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"title" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize author;
@synthesize initiatedBy;
@synthesize isbn;
@synthesize timeStamp;
@synthesize title;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListItem *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListItem *newObject = [[ax21_WishListItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "author")) {
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
				
					self.author = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "initiatedBy")) {
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
						elementClass = [ax21_InitiatedByEnum class];
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
				
					self.initiatedBy = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "isbn")) {
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
				
					self.isbn = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "timeStamp")) {
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
				
					self.timeStamp = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "title")) {
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
				
					self.title = newChild;
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
@implementation ax21_WishListProfile
- (id)init
{
	if((self = [super init])) {
		profileID = 0;
		profileName = 0;
		timestamp = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(profileID != nil) [profileID release];
	if(profileName != nil) [profileName release];
	if(timestamp != nil) [timestamp release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.profileID != 0) {
		xmlAddChild(node, [self.profileID xmlNodeForDoc:node->doc elementName:@"profileID" elementNSPrefix:@"ax21"]);
	}
	if(self.profileName != 0) {
		xmlAddChild(node, [self.profileName xmlNodeForDoc:node->doc elementName:@"profileName" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:profileName" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"profileName" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.timestamp != 0) {
		xmlAddChild(node, [self.timestamp xmlNodeForDoc:node->doc elementName:@"timestamp" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:timestamp" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"timestamp" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize profileID;
@synthesize profileName;
@synthesize timestamp;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListProfile *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListProfile *newObject = [[ax21_WishListProfile new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileID")) {
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
				
					self.profileID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileName")) {
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
				
					self.profileName = newChild;
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
@implementation ax21_WishListProfileItem
- (id)init
{
	if((self = [super init])) {
		itemList = [[NSMutableArray alloc] init];
		profile = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(itemList != nil) [itemList release];
	if(profile != nil) [profile release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.itemList != 0) {
		for(ax21_WishListItem * child in self.itemList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"itemList" elementNSPrefix:@"ax21"]);
		}
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:itemList" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"itemList" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.profile != 0) {
		xmlAddChild(node, [self.profile xmlNodeForDoc:node->doc elementName:@"profile" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:profile" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"profile" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize itemList;
- (void)addItemList:(ax21_WishListItem *)toAdd
{
	if(toAdd != nil) [itemList addObject:toAdd];
}
@synthesize profile;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListProfileItem *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListProfileItem *newObject = [[ax21_WishListProfileItem new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "itemList")) {
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
						elementClass = [ax21_WishListItem class];
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
				
					if(nilProperty == NO && newChild != nil) [self.itemList addObject:newChild];
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profile")) {
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
				
					self.profile = newChild;
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
@implementation ax21_WishListError
- (id)init
{
	if((self = [super init])) {
		errorCode = 0;
		errorMessage = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(errorCode != nil) [errorCode release];
	if(errorMessage != nil) [errorMessage release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.errorCode != 0) {
		xmlAddChild(node, [self.errorCode xmlNodeForDoc:node->doc elementName:@"errorCode" elementNSPrefix:@"ax21"]);
	}
	if(self.errorMessage != 0) {
		xmlAddChild(node, [self.errorMessage xmlNodeForDoc:node->doc elementName:@"errorMessage" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:errorMessage" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"errorMessage" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize errorCode;
@synthesize errorMessage;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListError *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListError *newObject = [[ax21_WishListError new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "errorCode")) {
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
				
					self.errorCode = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "errorMessage")) {
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
				
					self.errorMessage = newChild;
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
@implementation ax21_WishListItemStatus
- (id)init
{
	if((self = [super init])) {
		isbn = 0;
		itemError = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(isbn != nil) [isbn release];
	if(itemError != nil) [itemError release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.isbn != 0) {
		xmlAddChild(node, [self.isbn xmlNodeForDoc:node->doc elementName:@"isbn" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:isbn" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"isbn" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.itemError != 0) {
		xmlAddChild(node, [self.itemError xmlNodeForDoc:node->doc elementName:@"itemError" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:itemError" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"itemError" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize isbn;
@synthesize itemError;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListItemStatus *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListItemStatus *newObject = [[ax21_WishListItemStatus new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "isbn")) {
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
				
					self.isbn = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "itemError")) {
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
						elementClass = [ax21_WishListError class];
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
				
					self.itemError = newChild;
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
@implementation ax21_WishListProfileStatus
- (id)init
{
	if((self = [super init])) {
		itemStatusList = [[NSMutableArray alloc] init];
		profileError = 0;
		profileID = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(itemStatusList != nil) [itemStatusList release];
	if(profileError != nil) [profileError release];
	if(profileID != nil) [profileID release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.itemStatusList != 0) {
		for(ax21_WishListItemStatus * child in self.itemStatusList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"itemStatusList" elementNSPrefix:@"ax21"]);
		}
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:itemStatusList" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"itemStatusList" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.profileError != 0) {
		xmlAddChild(node, [self.profileError xmlNodeForDoc:node->doc elementName:@"profileError" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:profileError" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"profileError" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.profileID != 0) {
		xmlAddChild(node, [self.profileID xmlNodeForDoc:node->doc elementName:@"profileID" elementNSPrefix:@"ax21"]);
	}
}
/* elements */
@synthesize itemStatusList;
- (void)addItemStatusList:(ax21_WishListItemStatus *)toAdd
{
	if(toAdd != nil) [itemStatusList addObject:toAdd];
}
@synthesize profileError;
@synthesize profileID;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListProfileStatus *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListProfileStatus *newObject = [[ax21_WishListProfileStatus new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "itemStatusList")) {
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
						elementClass = [ax21_WishListItemStatus class];
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
				
					if(nilProperty == NO && newChild != nil) [self.itemStatusList addObject:newChild];
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileError")) {
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
						elementClass = [ax21_WishListError class];
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
				
					self.profileError = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileID")) {
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
				
					self.profileID = newChild;
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
@implementation ax21_WishListStatus
- (id)init
{
	if((self = [super init])) {
		profileStatusList = [[NSMutableArray alloc] init];
		spsID = 0;
		wishListError = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(profileStatusList != nil) [profileStatusList release];
	if(spsID != nil) [spsID release];
	if(wishListError != nil) [wishListError release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.profileStatusList != 0) {
		for(ax21_WishListProfileStatus * child in self.profileStatusList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileStatusList" elementNSPrefix:@"ax21"]);
		}
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:profileStatusList" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"profileStatusList" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.spsID != 0) {
		xmlAddChild(node, [self.spsID xmlNodeForDoc:node->doc elementName:@"spsID" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:spsID" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"spsID" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.wishListError != 0) {
		xmlAddChild(node, [self.wishListError xmlNodeForDoc:node->doc elementName:@"wishListError" elementNSPrefix:@"ax21"]);
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:wishListError" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"wishListError" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
}
/* elements */
@synthesize profileStatusList;
- (void)addProfileStatusList:(ax21_WishListProfileStatus *)toAdd
{
	if(toAdd != nil) [profileStatusList addObject:toAdd];
}
@synthesize spsID;
@synthesize wishListError;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishListStatus *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishListStatus *newObject = [[ax21_WishListStatus new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "profileStatusList")) {
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
						elementClass = [ax21_WishListProfileStatus class];
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
				
					if(nilProperty == NO && newChild != nil) [self.profileStatusList addObject:newChild];
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsID")) {
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
				
					self.spsID = newChild;
				}
			}
			if(xmlStrEqual(cur->name, (const xmlChar *) "wishListError")) {
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
						elementClass = [ax21_WishListError class];
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
				
					self.wishListError = newChild;
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
@implementation ax21_WishList
- (id)init
{
	if((self = [super init])) {
		profileItemList = [[NSMutableArray alloc] init];
		spsID = 0;
	}
	
	return self;
}
- (void)dealloc
{
	if(profileItemList != nil) [profileItemList release];
	if(spsID != nil) [spsID release];
	
	[super dealloc];
}
- (NSString *)nsPrefix
{
	return @"ax21";
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
		nodeName = [NSString stringWithFormat:@"%@:%@", @"ax21", elName];
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
	
	if(self.profileItemList != 0) {
		for(ax21_WishListProfileItem * child in self.profileItemList) {
			xmlAddChild(node, [child xmlNodeForDoc:node->doc elementName:@"profileItemList" elementNSPrefix:@"ax21"]);
		}
	} else {
		xmlNodePtr newnode;
		if([@"ax21" length] > 0) {
			newnode = xmlNewDocNode(node->doc, NULL, [@"ax21:profileItemList" xmlString], NULL);        
		} else {
			newnode = xmlNewDocNode(node->doc, NULL, [@"profileItemList" xmlString], NULL);        
		}
        xmlNewProp(newnode, (const xmlChar *)"xsi:nil", (const xmlChar *)"true");
        xmlAddChild(node, newnode);
	}
	if(self.spsID != 0) {
		xmlAddChild(node, [self.spsID xmlNodeForDoc:node->doc elementName:@"spsID" elementNSPrefix:@"ax21"]);
	}
}
/* elements */
@synthesize profileItemList;
- (void)addProfileItemList:(ax21_WishListProfileItem *)toAdd
{
	if(toAdd != nil) [profileItemList addObject:toAdd];
}
@synthesize spsID;
/* attributes */
- (NSDictionary *)attributes
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	
	return attributes;
}
+ (ax21_WishList *)deserializeNode:(xmlNodePtr)cur
{
	ax21_WishList *newObject = [[ax21_WishList new] autorelease];
	
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
			if(xmlStrEqual(cur->name, (const xmlChar *) "spsID")) {
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
				
					self.spsID = newChild;
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
