//
//  SCHEPubBook.m
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHEPubBook.h"
#import "SCHEPubParagraphSource.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"
#import <libEucalyptus/EucEPubDataProvider.h>
#import <libEucalyptus/EucEPubBookReference.h>

@interface SCHEPubBook ()

@property (nonatomic, retain) id <SCHBookPackageProvider> provider;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation SCHEPubBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize provider;

- (void)dealloc
{
    if (provider) {
        [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:identifier];
        [provider release], provider = nil;
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    SCHAppBook *book = [bookManager bookWithIdentifier:newIdentifier inManagedObjectContext:moc];
    identifier = nil;
    
    if (book) {
        provider = [[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
        
        if (provider) {
            
            EucEPubBookReference *bookReference = [[EucEPubBookReference alloc] initWithDataProvider:provider];
            NSString *aCacheDirectoryPath = [book libEucalyptusCache];
            if (aCacheDirectoryPath) {
                if ((self = [super initWithBookReference:bookReference cacheDirectoryPath:aCacheDirectoryPath])) {
                    identifier = [newIdentifier retain];
                    managedObjectContext = [moc retain];
                }
            }
            
            [bookReference release];
        }
    }
    
    if (!identifier) {
        [self release];
        self = nil;
    }
    
    return self;
}

- (NSArray *)userAgentCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    NSMutableArray *ret = [[[super userAgentCSSDatasForDocumentTree:documentTree] mutableCopy] autorelease];
    [ret addObject:[NSData dataWithContentsOfMappedFile:[[NSBundle mainBundle] pathForResource:@"ePubBaseOverrides" ofType:@"css"]]];
    return ret;
}

- (NSArray *)userCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    NSMutableArray *ret = [[[super userAgentCSSDatasForDocumentTree:documentTree] mutableCopy] autorelease];
    
    NSMutableString *cssString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SCHEPUB3Overrides" ofType:@"css"] 
                                                                  encoding:NSUTF8StringEncoding error:NULL];
    [cssString replaceOccurrencesOfString:@"%VIDEOPLACEHOLDERTEXT%" 
                               withString:NSLocalizedString(@"Sorry, this version of Storia cannot play embedded videos.", @"Placeholder text for EPUB3 video content") 
                                  options:0 
                                    range:NSMakeRange(0, cssString.length)];
    [cssString replaceOccurrencesOfString:@"%AUDIOPLACEHOLDERTEXT%" 
                               withString:NSLocalizedString(@"Sorry, this version of Storia cannot play embedded audio.", @"Placeholder text for EPUB3 audio content") 
                                  options:0 
                                    range:NSMakeRange(0, cssString.length)];
    
    if (cssString) {
        [ret addObject:[cssString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return ret;
}


- (SCHBookPoint *)bookPointFromBookPageIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    if(!indexPoint) {
        return nil;   
    } else {
        EucBookPageIndexPoint *eucIndexPoint = [indexPoint copy];
        
        // EucIndexPoint words start with word 0 == before the first word,
        // but Scholastic thinks that the first word is at 0.  This is a bit lossy,
        // but there's not much else we can do.
        if(eucIndexPoint.word == 0) {
            eucIndexPoint.element = 0;
        } else {
            eucIndexPoint.word -= 1;
        }    
        
        SCHBookPoint *ret = [[SCHBookPoint alloc] init];
        ret.layoutPage = eucIndexPoint.source + 1;
        ret.blockOffset = eucIndexPoint.block;
        ret.wordOffset = eucIndexPoint.word;
        ret.elementOffset = eucIndexPoint.element;
        
        [eucIndexPoint release];
        
        return [ret autorelease];    
    }
}

- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint
{
    if(!bookPoint) {
        return nil;   
    } else {
        EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
        
        eucIndexPoint.source = bookPoint.layoutPage - 1;
        eucIndexPoint.block = bookPoint.blockOffset;
        eucIndexPoint.word = bookPoint.wordOffset;
        eucIndexPoint.element = bookPoint.elementOffset;
        
        // EucIndexPoint words start with word 0 == before the first word,
        // but Blio thinks that the first word is at 0.  This is a bit lossy,
        // but there's not much else we can do.    
        eucIndexPoint.word += 1;
        
        return [eucIndexPoint autorelease];  
    }
}

@end
