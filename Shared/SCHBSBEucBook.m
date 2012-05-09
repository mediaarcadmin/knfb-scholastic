//
//  SCHBSBEucBook.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBEucBook.h"
#import "SCHBookPackageProvider.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHBookPoint.h"

@interface SCHBSBEucBook()

@property (nonatomic, retain) id <SCHBookPackageProvider> provider;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation SCHBSBEucBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize provider;
@synthesize cacheDirectoryPath;

- (void)dealloc
{
    if (provider) {
        [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:identifier];
        [provider release], provider = nil;
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [cacheDirectoryPath release], cacheDirectoryPath = nil;
     
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{    
    
    if ((self = [super init])) {
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:newIdentifier inManagedObjectContext:moc];
        
        if (book) {
            provider = [[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
            
            if (provider) {
                cacheDirectoryPath = [[book libEucalyptusCache] retain];
            }
            
            if (cacheDirectoryPath) {
                identifier = [newIdentifier retain];
            }
        }
        
        if (!identifier) {
            [self release];
            self = nil;
        }
    }
    
    return self;
}

#pragma mark - EucBook

- (NSString *)cacheDirectoryPath
{
    return  nil;
}

- (Class)pageLayoutControllerClass
{
    return nil;
}

- (Class)pageContentsViewSpiritClass
{
    return nil;
}

- (NSArray *)navPoints
{
    return nil;
}

- (EucBookNavPoint *)navPointWithUuid:(NSString *)uuid
{
    return nil;
}

- (EucBookPageIndexPoint *)indexPointForUuid:(NSString *)identifier
{
    return nil;
}

- (float)estimatedPercentageForIndexPoint:(EucBookPageIndexPoint *)point
{
    return 0.0f;
}

- (EucBookPageIndexPoint *)estimatedIndexPointForPercentage:(float)percentage
{
    return nil;
}

- (EucBookPageIndexPoint *)offTheEndIndexPoint
{
    return nil;
}

- (NSArray *)hardPageBreakIndexPoints
{
    return nil;
}

- (BOOL)fullBleedPageForIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return NO;
}

- (NSString *)stringForIndexPointRange:(EucBookPageIndexPointRange *)indexPointRange
{
    return nil;
}

#pragma mark - EucBookReference

- (NSString *)uniqueIdentifier
{
    return nil;
}

- (NSString *)title
{
    return nil;
}

- (NSString *)author
{
    return nil;
}

- (NSData *)coverImageData
{
    return nil;
}

- (NSString *)humanReadableAuthor
{
    return nil;
}

- (NSString *)humanReadableTitle
{
    return nil;
}

#pragma mark - SCHEucBookmarkPointTranslation

- (SCHBookPoint *)bookPointFromBookPageIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    return nil;
}

- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint
{
    return nil;
}

@end
