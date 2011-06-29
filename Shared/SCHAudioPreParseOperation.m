//
//  SCHAudioPreParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 19/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioPreParseOperation.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "KNFBXPSConstants.h"

#pragma mark - Class Extension

@interface SCHAudioPreParseOperation ()

@property BOOL success;
@property BOOL parsingComplete;

@property (nonatomic, retain) NSXMLParser *audioInfoParser;
@property (nonatomic, retain) NSMutableArray *audioFiles;
@property (nonatomic, retain) NSMutableArray *timingFiles;

@end

#pragma mark -

@implementation SCHAudioPreParseOperation

@synthesize success;
@synthesize parsingComplete;
@synthesize audioInfoParser;
@synthesize audioFiles;
@synthesize timingFiles;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
    [audioInfoParser release], audioInfoParser = nil;
    [audioFiles release], audioFiles = nil;
    [timingFiles release], timingFiles = nil;
    
	[super dealloc];
}

#pragma mark - Book Operation methods

- (void)start
{
	if (self.isbn && ![self isCancelled]) {
		self.success = YES;
		[super start];
	}
}

- (void)beginOperation
{
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn 
                                                                                    inManagedObjectContext:self.localManagedObjectContext];
	
	// check for audiobook reference file
	NSData *audiobookReferencesFile = [xpsProvider dataForComponentAtPath:KNFBXPSAudiobookReferencesFile];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
	if (audiobookReferencesFile) {
		self.parsingComplete = NO;
        self.audioFiles = [NSMutableArray array];
        self.timingFiles = [NSMutableArray array];
        self.audioInfoParser = [[[NSXMLParser alloc] initWithData:audiobookReferencesFile] autorelease];
		[self.audioInfoParser setDelegate:self];
		[self.audioInfoParser parse];
        
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.parsingComplete);
		
	}
	
	if (self.success) {
        [self threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForTextFlowPreParse];
	} else {
        [self threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateBookVersionNotSupported];
	}
    
    [self setBook:self.isbn isProcessing:NO];
    [self endOperation];
	
	return;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString:@"Audio"]) {
        NSString *audioFile = [attributeDict objectForKey:@"src"];
        
        if (audioFile) {
            [self.audioFiles addObject:audioFile];
        }
    }
    else if ([elementName isEqualToString:@"Timing"]) {		
        NSString *timingFile = [attributeDict objectForKey:@"src"];
        
        if (timingFile) {
            [self.timingFiles addObject:timingFile];
        }
    }    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSInteger count = [self.audioFiles count];
    NSMutableArray *audioBookReferences = [NSMutableArray array];
    
	self.parsingComplete = YES;
    
    for (NSInteger i = 0; i < count; i++) { 
        [audioBookReferences addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:[self.audioFiles objectAtIndex:i], kSCHAppBookAudioFile,
          [self.timingFiles objectAtIndex:i], kSCHAppBookTimingFile, nil]];
    }
    
    [self withBook:self.isbn perform:^(SCHAppBook *book) {
        [book setValue:audioBookReferences forKey:kSCHAppBookAudioBookReferences];
    }];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	self.success = NO;
	self.parsingComplete = YES;
}


@end
