//
//  SCHLocalDebugXPSReader.m
//  Scholastic
//
//  Created by Gordon Christie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLocalDebugXPSReader.h"
#import "zlib.h"
#import "TouchXML.h"
#import "KNFBXPSConstants.h"


@interface SCHLocalDebugXPSReader()

@property (nonatomic, retain) NSString *tempDirectory;
@property (nonatomic, retain) NSMutableDictionary *xpsData;
@property (nonatomic, retain) NSString *xpsPagesDirectory;
@property (nonatomic, retain) NSMutableArray *uriMap;

- (void)parseMetadata:(NSData *)metadataFile;
- (void)deleteTemporaryDirectoryAtPath:(NSString *)path;
- (NSData *)decompressWithRawDeflate:(NSData *)data;
- (NSData *)decompressWithGZipCompression:(NSData *)data;
- (NSData *)decompress:(NSData *)data windowBits:(NSInteger)windowBits;
- (NSData *)dataForComponentAtPath:(NSString *)path;
- (NSData *)replaceMappedResources:(NSData *)data;
- (NSString *)extractFixedDocumentPath:(NSData *)data;
- (NSString *)extractFixedPagesPath:(NSData *)data;

@end




@implementation SCHLocalDebugXPSReader

@synthesize tempDirectory, xpsData, xpsPagesDirectory, uriMap;
@synthesize ISBN, pageCount, author, title, fileName, fileSize, type;

- (id) init
{
	return [self initWithPath:nil];
}

- (id) initWithPath:(NSString *)path
{
	self = [super init];
	if (self != nil) {
		
		if (path) {
			
			inflateLock = [[NSLock alloc] init];
			
			CFUUIDRef theUUID = CFUUIDCreate(NULL);
			CFStringRef UUIDString = CFUUIDCreateString(NULL, theUUID);
			CFRelease(theUUID);
			self.tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:(NSString *)UUIDString];
			
			NSError *error;
			
			if (![[NSFileManager defaultManager] fileExistsAtPath:self.tempDirectory]) {
				if (![[NSFileManager defaultManager] createDirectoryAtPath:self.tempDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
					NSLog(@"Unable to create temp XPS directory at path %@ with error %@ : %@", self.tempDirectory, error, [error userInfo]);
					CFRelease(UUIDString);
					return nil;
				}
			}
			
			XPS_Start();

			if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
				NSLog(@"Error creating debugXPSReader. File does not exist at path: %@", path);
				CFRelease(UUIDString);
				return nil;
			}
			
			xpsHandle = XPS_Open([path UTF8String], [self.tempDirectory UTF8String]);
			
			CFRelease(UUIDString);
			
			XPS_SetAntiAliasMode(xpsHandle, XPS_ANTIALIAS_ON);
			self.pageCount = XPS_GetNumberPages(xpsHandle, 0);
			
			NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
			self.fileSize = fileAttributes.fileSize;
			
			[self parseMetadata:[self dataForComponentAtPath:KNFBXPSKNFBMetadataFile]];
			
			self.xpsData = [NSMutableDictionary dictionary];
			
			[self parseMetadata:[self dataForComponentAtPath:KNFBXPSKNFBMetadataFile]];
		}
		
	} 
	
	return self;
}

- (NSData *)rawDataForComponentAtPath:(NSString *)path {
    NSData *rawData = nil;
    
    XPS_FILE_PACKAGE_INFO packageInfo;
	
    int ret = XPS_GetComponentInfo(xpsHandle, (char *)[path UTF8String], &packageInfo);

    if (!ret) {
        NSLog(@"Nothing returned from getcomponentinfo. Error opening component at path %@", path);
        return nil;
    } else {
        NSData *packageData = [NSMutableData dataWithBytes:packageInfo.pComponentData length:packageInfo.length];
        //NSLog(@"Raw data length %d (%d) with compression %d", [rawData length], packageInfo.length, packageInfo.compression_type);
        if (packageInfo.compression_type == 8) {
            rawData = [self decompressWithRawDeflate:packageData];
            if ([rawData length] == 0) {
                NSLog(@"Error decompressing component at path %@", path);
            }
        } else {
            rawData = packageData;
        }
    }
    
    if ([rawData length] == 0) {
        NSLog(@"No data. Error opening component at path %@", path);
        return nil;
    }
    
    return rawData;
}

- (NSData *)dataForComponentAtPath:(NSString *)path {
    NSString *componentPath = path;
    NSString *extension = [[path pathExtension] uppercaseString];
	
    BOOL mapped = NO;
    
    // TODO: Make sure these checks are ordered from most common to least common for efficiency
	if ([extension isEqualToString:[KNFBXPSComponentExtensionFPage uppercaseString]]) {
		componentPath = [[self xpsPagesDirectory] stringByAppendingPathComponent:path];
        mapped = YES;
    }
	
    NSData *componentData = [self rawDataForComponentAtPath:componentPath];

    if (mapped) {
        componentData = [self replaceMappedResources:componentData];
    }
    
    if (![componentData length]) {
        NSLog(@"Zero length data returned in dataForComponentAtPath: %@", path);
    }
    
    return componentData;
    
}

- (NSString *)xpsPagesDirectory {
	if (!xpsPagesDirectory) {
		NSData *sequenceData = [self dataForComponentAtPath:KNFBXPSTextFlowSectionsFile];
		NSString *fixedDocumentPath = [self extractFixedDocumentPath:sequenceData];
		
		if (fixedDocumentPath) {
			NSData *fixedDocumentData = [self dataForComponentAtPath:fixedDocumentPath];
			NSString *pagesPath = [self extractFixedPagesPath:fixedDocumentData];
			if ([[pagesPath substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
				xpsPagesDirectory = pagesPath;
			} else {
				if (![[fixedDocumentPath substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
					fixedDocumentPath = [NSString stringWithFormat:@"/%@", fixedDocumentPath];
				}
				xpsPagesDirectory = [[fixedDocumentPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:pagesPath];
			}
			[xpsPagesDirectory retain];
		}
		
	}
	
	return xpsPagesDirectory ? xpsPagesDirectory : @"";
}

- (NSData *)replaceMappedResources:(NSData *)data {
    NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:[inputString length]];
	
    NSString *GRIDROW = @"Grid.Row=\"";
    NSString *CLOSINGQUOTE = @"\"";
    
    NSScanner *aScanner = [NSScanner scannerWithString:inputString];
    
    while ([aScanner isAtEnd] == NO)
    {
        NSUInteger startPos = [aScanner scanLocation];
        [aScanner scanUpToString:GRIDROW intoString:NULL];
        NSUInteger endPos = [aScanner scanLocation];
        NSRange prefixRange = NSMakeRange(startPos, endPos - startPos);
        [outputString appendString:[inputString substringWithRange:prefixRange]];
        
        if ([aScanner isAtEnd] == NO) {
            // Skip the gridrow entry
            [aScanner scanString:GRIDROW intoString:NULL];
            
            // Read the row digit, insert the lookup and advance passed the closing quote
            NSInteger anInteger;
            if ([aScanner scanInteger:&anInteger]) {
                if (anInteger < [self.uriMap count]) {
                    [outputString appendString:[NSString stringWithFormat:@"ImageSource=\"%@\" ", [self.uriMap objectAtIndex:anInteger]]];
                } else {
                    NSLog(@"Warning: could not find mapped resource for Grid.Row %d. Mapping count is %d", anInteger, [self.uriMap count]);
                }
            }
            // Skip the closing quote
            [aScanner scanString:CLOSINGQUOTE intoString:NULL];
        }
    }
    [inputString release];
    
    if ([outputString length]) {
        data = [outputString dataUsingEncoding:NSUTF8StringEncoding];
    }
    [outputString release];
    
    return data;
}




- (void)parseMetadata:(NSData *)metadataFile
{
	NSError *error = nil;
	CXMLDocument *doc = [[CXMLDocument alloc] initWithData:metadataFile options:0 error:&error];
	NSArray *nodes = nil;
	
	if (error == nil) {
		nodes = [doc nodesForXPath:@"//Title" error:&error];
		if (error == nil) {		
			for (CXMLElement *node in nodes) {
				self.title = [[node attributeForName:@"Main"] stringValue];
			}	
		}
		nodes = [doc nodesForXPath:@"//Contributor" error:&error];
		if (error == nil) {		
			for (CXMLElement *node in nodes) {
				self.author = [[node attributeForName:@"Author"] stringValue];
			}	
		}		
		nodes = [doc nodesForXPath:@"//Identifier" error:&error];
		if (error == nil) {		
			for (CXMLElement *node in nodes) {
				self.ISBN = [[node attributeForName:@"ISBN"] stringValue];
			}	
		}		
		nodes = [doc nodesForXPath:@"//Source" error:&error];
		if (error == nil) {		
			for (CXMLElement *node in nodes) {
				self.type = [[node attributeForName:@"Type"] stringValue];
			}	
		}		
	}
	
	[doc release], doc = nil;
}

#pragma mark -
#pragma mark Decompression

- (NSData *)decompressWithRawDeflate:(NSData *)data {
    return [self decompress:data windowBits:-15];
}

- (NSData *)decompressWithGZipCompression:(NSData *)data {
    return [self decompress:data windowBits:31];
}

- (NSData *)decompress:(NSData *)data windowBits:(NSInteger)windowBits {
    
	int ret;
	unsigned bytesDecompressed;
	z_stream strm;
	const int BUFSIZE=16384;
	unsigned char outbuf[BUFSIZE];
	NSMutableData* outData = [[NSMutableData alloc] init];
	
	// Read the gzip header.
	// TESTING
	//unsigned char ID1 = inBuffer[0];  // should be x1f
	//unsigned char ID2 = inBuffer[1];  // should be x8b
	//unsigned char CM = inBuffer[2];   // should be 8
	
	// Allocate inflate state.
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.avail_in = 0;
	strm.next_in = Z_NULL;
	
    [inflateLock lock];
    
	ret = XPS_inflateInit2(&strm, windowBits);
	
	if (ret != Z_OK) {
        [inflateLock unlock];
        [outData release];
		return nil;
    }
	
	strm.avail_in = [data length];
	strm.next_in = (Bytef *)[data bytes];
	// Inflate until the output buffer isn't full
	do {
		strm.avail_out = BUFSIZE;
		strm.next_out = outbuf;
		ret = XPS_inflate(&strm,Z_NO_FLUSH); 
		// ret should be Z_STREAM_END
		switch (ret) {
			case Z_NEED_DICT:
				//ret = Z_DATA_ERROR;
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				XPS_inflateEnd(&strm);
                [inflateLock unlock];
                [outData release];
				return nil;
		}
		bytesDecompressed = BUFSIZE - strm.avail_out;
		NSData* data = [[NSData alloc] initWithBytesNoCopy:outbuf length:bytesDecompressed freeWhenDone:NO];
		[outData appendData:data];
        [data release];
	}
	while (strm.avail_out == 0);
	XPS_inflateEnd(&strm);
	
    [inflateLock unlock];
	
	if (ret == Z_STREAM_END || ret == Z_OK)
		return [outData autorelease];
    
    [outData release];
	return nil;
}

- (NSString *)extractFixedDocumentPath:(NSData *)data {
	NSString *docRefString = nil;
	
	if (data) {
		NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		NSString *DOCREF = @"<DocumentReference";
		NSString *QUOTE = @"\"";
		
		NSScanner *aScanner = [NSScanner scannerWithString:inputString];
		
		while ([aScanner isAtEnd] == NO)
		{
			
			[aScanner scanUpToString:DOCREF intoString:NULL];
			[aScanner scanString:DOCREF intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:NULL];
			[aScanner scanString:QUOTE intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:&docRefString];
			break;
		}
		[inputString release];
	}
	
	return docRefString;
}

- (NSString *)extractFixedPagesPath:(NSData *)data {
	NSString *pageContentString = nil;
	NSString *fixedPagesString = nil;
	
	if (data) {
		NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		NSString *PAGECONTENT = @"<PageContent";
		NSString *QUOTE = @"\"";
		
		NSScanner *aScanner = [NSScanner scannerWithString:inputString];
		
		while ([aScanner isAtEnd] == NO)
		{
			
			[aScanner scanUpToString:PAGECONTENT intoString:NULL];
			[aScanner scanString:PAGECONTENT intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:NULL];
			[aScanner scanString:QUOTE intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:&pageContentString];
			
			if (pageContentString) {
				fixedPagesString = [NSString stringWithString:[pageContentString stringByDeletingLastPathComponent]];
				break;
			}
			
		}
		[inputString release];
	}
	
	return fixedPagesString;
}


- (void)deleteTemporaryDirectoryAtPath:(NSString *)path {
    // Should have been deleted by XPS cleanup but remove if not
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    NSFileManager *threadSafeManager = [[NSFileManager alloc] init];
    if ([threadSafeManager fileExistsAtPath:path]) {
        //NSLog(@"Removing temp XPS directory at path %@", path);
		
        if (![threadSafeManager removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing temp XPS directory at path %@ with error %@ : %@", path, error, [error userInfo]);
        }
    }
    [threadSafeManager release];
    [pool drain];
}



- (void) close
{
	
}

- (void) dealloc
{
	[self deleteTemporaryDirectoryAtPath:self.tempDirectory];
    XPS_Cancel(xpsHandle);
    XPS_Close(xpsHandle);
    XPS_End();
    xpsHandle = nil;
	
	[inflateLock release];
	
	[super dealloc];
}


@end
