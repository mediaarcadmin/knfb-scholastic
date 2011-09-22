//
//  SCHPopulateDataStore.m
//  Scholastic
//
//  Created by John S. Eddie on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPopulateDataStore.h"

#import "SCHProfileSyncComponent.h"
#import "SCHContentSyncComponent.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHReadingStatsSyncComponent.h"
#import "SCHSettingsSyncComponent.h"
#import "SCHAppStateManager.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"
#import "TouchXML.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"

@interface SCHPopulateDataStore ()

- (void)addBook:(NSDictionary *)book forProfiles:(NSArray *)profileIDs;
- (void)setAppStateForSample;
- (NSDictionary *)profileItemWith:(NSInteger)profileID
                            title:(NSString *)title 
                         password:(NSString *)password
                              age:(NSUInteger)age 
                        bookshelf:(SCHBookshelfStyles)bookshelf;
- (NSDictionary *)contentMetaDataItemWith:(NSString *)contentIdentifier
                                    title:(NSString *)title
                                   author:(NSString *)author
                               pageNumber:(NSInteger)pageNumber
                                 fileSize:(long long)fileSize
                              drmQualifer:(SCHDRMQualifiers)drmQualifer
                                 coverURL:(NSString *)coverURL
                               contentURL:(NSString *)contentURL
                                 enhanced:(BOOL)enhanced;
- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier 
                          drmQualifer:(SCHDRMQualifiers)drmQualifer
                           profileIDs:(NSArray *)profileIDs;
- (NSArray *)listXPSFilesFrom:(NSString *)directory;
- (BOOL)populateBook:(NSString *)xpsFilePath profileIDs:(NSArray *)profileIDs;

@end

@implementation SCHPopulateDataStore

@synthesize managedObjectContext;
@synthesize profileSyncComponent;
@synthesize contentSyncComponent;
@synthesize bookshelfSyncComponent;
@synthesize annotationSyncComponent;
@synthesize readingStatsSyncComponent;
@synthesize settingsSyncComponent;

#pragma mark - Lifecycle methods

- (void)dealloc
{
    [managedObjectContext release], managedObjectContext = nil;
	[profileSyncComponent release], profileSyncComponent = nil;
	[contentSyncComponent release], contentSyncComponent = nil;
	[bookshelfSyncComponent release], bookshelfSyncComponent = nil;
	[annotationSyncComponent release], annotationSyncComponent = nil;
	[readingStatsSyncComponent release], readingStatsSyncComponent = nil;
	[settingsSyncComponent release], settingsSyncComponent = nil;
	
	[super dealloc];
}

#pragma mark - Population methods

- (void)populateTestSampleStore
{
    NSError *error = nil;
    
    [self setAppStateForSample];    
    
    // Younger bookshelf    
    NSDictionary *youngerProfileItem = [self profileItemWith:1
                                                       title:NSLocalizedString(@"Bookshelf #1", nil) 
                                                    password:@"pass"                                 
                                                         age:5 
                                                   bookshelf:kSCHBookshelfStyleYoungChild];
    [self.profileSyncComponent addProfile:youngerProfileItem];
    
    // Older bookshelf    
    NSDictionary *olderProfileItem = [self profileItemWith:2
                                                     title:NSLocalizedString(@"Bookshelf #2", nil) 
                                                  password:@"pass"                                 
                                                       age:14 
                                                 bookshelf:kSCHBookshelfStyleOlderChild];
    [self.profileSyncComponent addProfile:olderProfileItem];
    
    NSArray *youngerBookshelfOnly = [NSArray arrayWithObject:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID]];
    NSArray *olderBookshelfOnly = [NSArray arrayWithObject:[olderProfileItem objectForKey:kSCHLibreAccessWebServiceID]];
    NSArray *allBookshelves = [NSArray arrayWithObjects:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID],
                               [olderProfileItem objectForKey:kSCHLibreAccessWebServiceID], 
                               nil];
    
    // Books
    NSDictionary *book1 = [self contentMetaDataItemWith:@"9780545283502"
                                                  title:@"Classic Goosebumps: Night of the Living Dummy"
                                                 author:@"R.L. Stine"
                                             pageNumber:162
                                               fileSize:4142171
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545283502.NightOfTheLivingDummy.jpg"
                                             contentURL:@"9780545283502.NightOfTheLivingDummy.xps"
                                               enhanced:YES];
    [self addBook:book1 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book2 = [self contentMetaDataItemWith:@"9780545287012"
                                                  title:@"Scholastic Reader Level 1: Clifford and the Halloween Parade"
                                                 author:@"Norman Bridwell"
                                             pageNumber:34
                                               fileSize:5149305
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545287012_r1.HalloweenParade.jpg"
                                             contentURL:@"9780545287012_r1.HalloweenParade.xps"
                                               enhanced:YES];
    [self addBook:book2 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book3 = [self contentMetaDataItemWith:@"9780545289726"
                                                  title:@"Ollie's New Tricks"
                                                 author:@"by True Kelley, illustrated by True Kelley"
                                             pageNumber:34
                                               fileSize:21251026
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545289726_r1.OlliesNewTricks.jpg"
                                             contentURL:@"9780545289726_r1.OlliesNewTricks.xps"
                                               enhanced:YES];
    [self addBook:book3 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book4 = [self contentMetaDataItemWith:@"9780545345019"
                                                  title:@"Allie Finkle's Rules for Girls: Moving Day"
                                                 author:@"Meg Cabot"
                                             pageNumber:258
                                               fileSize:5620118
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545345019_r1.AllieFinkleMovingDay.jpg"
                                             contentURL:@"9780545345019_r1.AllieFinkleMovingDay.xps"
                                               enhanced:YES];
    [self addBook:book4 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book5 = [self contentMetaDataItemWith:@"9780545327619"
                                                  title:@"Who Will Carve the Turkey This Thanksgiving?"
                                                 author:@"by Jerry Pallotta, illustrated by David Biedrzycki"
                                             pageNumber:35
                                               fileSize:5808879
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545327619_r1.WhoWillCarveTheTurkey.jpg"
                                             contentURL:@"9780545327619_r1.WhoWillCarveTheTurkey.xps"
                                               enhanced:YES];
    [self addBook:book5 forProfiles:youngerBookshelfOnly];
    
    NSDictionary *book6 = [self contentMetaDataItemWith:@"9780545366779"
                                                  title:@"The 39 Clues Book 1: The Maze of Bones"
                                                 author:@"Rick Riordan"
                                             pageNumber:247
                                               fileSize:9280193
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545366779.2.MazeOfBones.jpg"
                                             contentURL:@"9780545366779.2.MazeOfBones.xps"
                                               enhanced:YES];
    [self addBook:book6 forProfiles:olderBookshelfOnly];
    
    NSDictionary *book7 = [self contentMetaDataItemWith:@"9780545308656"
                                                  title:@"Scholastic Reader Level 3: Stablemates: Patch"
                                                 author:@"by Kristin Earhart, illustrated by Lisa Papp"
                                             pageNumber:42
                                               fileSize:11099476
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545308656.6.StableMatesPatch.jpg"
                                             contentURL:@"9780545308656.6.StableMatesPatch.xps"
                                               enhanced:YES];
    [self addBook:book7 forProfiles:allBookshelves];
    
    NSDictionary *book8 = [self contentMetaDataItemWith:@"9780545368896"
                                                  title:@"The Secrets of Droon #1: The Hidden Stairs and the Magic Carpet"
                                                 author:@"by Tony Abbott, illustrated by Tim Jessell"
                                             pageNumber:98
                                               fileSize:2794624
                                            drmQualifer:kSCHDRMQualifiersFullNoDRM
                                               coverURL:@"9780545368896_r1.TheHiddenStairs.jpg"
                                             contentURL:@"9780545368896_r1.TheHiddenStairs.xps"
                                               enhanced:YES];
    [self addBook:book8 forProfiles:olderBookshelfOnly]; 
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)addBook:(NSDictionary *)book forProfiles:(NSArray *)profileIDs
{
    if (book != nil && profileIDs != nil && [profileIDs count] > 0) {
        [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier]
                                                                    drmQualifer:[[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue]
                                                                     profileIDs:profileIDs]];
        
        [self.bookshelfSyncComponent addContentMetadataItem:book];
    }
}

- (NSUInteger)populateFromImport
{
    NSError *error = nil;
    NSArray *documentDirectorys = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = ([documentDirectorys count] > 0) ? [documentDirectorys objectAtIndex:0] : nil;
    NSUInteger ret = 0;
    
    if (documentDirectory != nil) {
        for (NSString *xpsFilePath in [self listXPSFilesFrom:documentDirectory]) {
            // use the first profile which we expect to be profileID 1
            if ([self populateBook:xpsFilePath profileIDs:[NSArray arrayWithObject:[NSNumber numberWithInteger:1]]] == YES) {
                ret++;
            }
        }
        
        if ([self.managedObjectContext save:&error] == NO) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }                 
    }
    
    return(ret);
}

- (NSArray *)listXPSFilesFrom:(NSString *)directory
{
    NSMutableArray *ret = nil;
    NSError *error = nil;
    
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory 
                                                                                     error:&error];	
	if (error != nil) {
		NSLog(@"Error retreiving XPS files: %@", [error localizedDescription]);
	} else {
        ret = [NSMutableArray arrayWithCapacity:[directoryContents count]];
        for (NSString *fileName in [directoryContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]]) {
            [ret addObject:[directory stringByAppendingPathComponent:fileName]];
        }        
    }
    
    return(ret);
}

#pragma mark - Sample bookshelf population methods

- (void)populateSampleStore
{
    NSError *error = nil;
    
    [self setAppStateForSample];    
    
    // Younger bookshelf    
    NSDictionary *youngerProfileItem = [self profileItemWith:1
                                                       title:NSLocalizedString(@"Younger kids' bookshelf (3-6)", nil) 
                                                    password:@"pass"                                 
                                                         age:5 
                                                   bookshelf:kSCHBookshelfStyleYoungChild];
    [self.profileSyncComponent addProfile:youngerProfileItem];
    
    NSDictionary *youngerBook = [self contentMetaDataItemWith:@"0-393-05158-7"
                                                        title:@"A Christmas Carol"
                                                       author:@"Charles Dickens"
                                                   pageNumber:1
                                                     fileSize:862109
                                                  drmQualifer:kSCHDRMQualifiersSample
                                                     coverURL:@"http://bitwink.com/private/ChristmasCarol.jpg"
                                                   contentURL:@"http://bitwink.com/private/ChristmasCarol.xps"
                                                     enhanced:NO];
    [self addBook:youngerBook forProfiles:[NSArray arrayWithObject:[youngerProfileItem objectForKey:kSCHLibreAccessWebServiceID]]];
    
    // Older bookshelf    
    NSDictionary *olderProfileItem = [self profileItemWith:2
                                                     title:NSLocalizedString(@"Older kids' bookshelf (7+)", nil) 
                                                  password:@"pass"
                                                       age:14 
                                                 bookshelf:kSCHBookshelfStyleOlderChild];
    [self.profileSyncComponent addProfile:olderProfileItem];
    
    NSDictionary *olderBook = [self contentMetaDataItemWith:@"978-0-14-143960-0"
                                                      title:@"A Tale of Two Cities"
                                                     author:@"Charles Dickens"
                                                 pageNumber:1
                                                   fileSize:4023944
                                                drmQualifer:kSCHDRMQualifiersSample
                                                   coverURL:@"http://bitwink.com/private/ATaleOfTwoCities.jpg"
                                                 contentURL:@"http://bitwink.com/private/ATaleOfTwoCities.xps"
                                                   enhanced:NO];
    [self addBook:olderBook forProfiles:[NSArray arrayWithObject:[olderProfileItem objectForKey:kSCHLibreAccessWebServiceID]]];
    
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }     
}

- (void)setAppStateForSample
{
    SCHAppState *appState = [SCHAppStateManager sharedAppStateManager].appState;
    
    appState.ShouldSync = [NSNumber numberWithBool:NO];
    appState.ShouldAuthenticate = [NSNumber numberWithBool:NO];
    appState.DataStoreType = [NSNumber numberWithDataStoreType:kSCHDataStoreTypesSample];
}

#pragma mark - Core Data population methods

- (NSDictionary *)profileItemWith:(NSInteger)profileID
                            title:(NSString *)title 
                         password:(NSString *)password
                              age:(NSUInteger)age 
                        bookshelf:(SCHBookshelfStyles)bookshelf
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSDate *dateNow = [NSDate date];
    NSCalendar *gregorian = [[[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComponents = [[[NSDateComponents alloc] init] autorelease];        
    
    [ret setObject:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceStoryInteractionEnabled];
    [ret setObject:[NSNumber numberWithInteger:profileID] forKey:kSCHLibreAccessWebServiceID];
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastPasswordModified];    
    [ret setObject:password forKey:kSCHLibreAccessWebServicePassword]; 
    dateComponents.year = -age;
    [ret setObject:[gregorian dateByAddingComponents:dateComponents toDate:dateNow options:0] forKey:kSCHLibreAccessWebServiceBirthday];    
    [ret setObject:title forKey:kSCHLibreAccessWebServiceFirstName];    
    [ret setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceProfilePasswordRequired];    
    [ret setObject:[NSNumber numberWithProfileType:kSCHProfileTypesCHILD] forKey:kSCHLibreAccessWebServiceType];        
    [ret setObject:title forKey:kSCHLibreAccessWebServiceScreenName];        
    [ret setObject:[NSNumber numberWithBool:YES] forKey:kSCHLibreAccessWebServiceAutoAssignContentToProfiles];        
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastScreenNameModified];            
    [ret setObject:@"" forKey:kSCHLibreAccessWebServiceUserKey];            
    [ret setObject:[NSNumber numberWithBookshelfStyle:bookshelf] forKey:kSCHLibreAccessWebServiceBookshelfStyle];                
    [ret setObject:title forKey:kSCHLibreAccessWebServiceLastName];                
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];                
    
    return(ret);
}

- (NSDictionary *)contentMetaDataItemWith:(NSString *)contentIdentifier
                                    title:(NSString *)title
                                   author:(NSString *)author
                               pageNumber:(NSInteger)pageNumber
                                 fileSize:(long long)fileSize
                              drmQualifer:(SCHDRMQualifiers)drmQualifer
                                 coverURL:(NSString *)coverURL
                               contentURL:(NSString *)contentURL
                                 enhanced:(BOOL)enhanced
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];    
    
    [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [ret setObject:[NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [ret setObject:title forKey:kSCHLibreAccessWebServiceTitle];
    [ret setObject:author forKey:kSCHLibreAccessWebServiceAuthor];
    [ret setObject:[NSString stringWithFormat:@"A book by %@", author] forKey:kSCHLibreAccessWebServiceDescription];
    [ret setObject:@"1" forKey:kSCHLibreAccessWebServiceVersion];
    [ret setObject:[NSNumber numberWithInteger:pageNumber] forKey:kSCHLibreAccessWebServicePageNumber];
    [ret setObject:[NSNumber numberWithLongLong:fileSize] forKey:kSCHLibreAccessWebServiceFileSize];
    [ret setObject:[NSNumber numberWithDRMQualifier:drmQualifer] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:(coverURL == nil ? (id)[NSNull null] : coverURL) forKey:kSCHLibreAccessWebServiceCoverURL];
    [ret setObject:(contentURL == nil ? (id)[NSNull null] : contentURL) forKey:kSCHLibreAccessWebServiceContentURL];
    [ret setObject:[NSNull null] forKey:kSCHLibreAccessWebServiceeReaderCategories];
    [ret setObject:[NSNumber numberWithBool:enhanced] forKey:kSCHLibreAccessWebServiceEnhanced];
    
    return(ret);    
}

- (NSDictionary *)userContentItemWith:(NSString *)contentIdentifier
                          drmQualifer:(SCHDRMQualifiers)drmQualifer
                           profileIDs:(NSArray *)profileIDs
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];    
    NSDate *dateNow = [NSDate date];
    
    NSMutableArray *profileList = [NSMutableArray arrayWithCapacity:[profileIDs count]];
    NSMutableArray *orderList = [NSMutableArray arrayWithCapacity:[profileIDs count]];    
    NSInteger orderID = 1;
    for (NSNumber *profileID in profileIDs) {
        NSMutableDictionary *profileItem = [NSMutableDictionary dictionary];
        [profileItem setObject:profileID forKey:kSCHLibreAccessWebServiceProfileID];        
        [profileItem setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceIsFavorite];        
        [profileItem setObject:[NSNumber numberWithInteger:0] forKey:kSCHLibreAccessWebServiceLastPageLocation];            
        [profileItem setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];        
        [profileList addObject:profileItem];
        
        NSMutableDictionary *orderItem = [NSMutableDictionary dictionary];
        [orderItem setObject:[NSString stringWithFormat:@"%lx", orderID++] forKey:kSCHLibreAccessWebServiceOrderID];        
        [orderItem setObject:[dateNow dateByAddingTimeInterval:orderID * 60] forKey:kSCHLibreAccessWebServiceOrderDate];                
        [orderList addObject:orderItem];
    }
    
    [ret setObject:contentIdentifier forKey:kSCHLibreAccessWebServiceContentIdentifier];
    [ret setObject:[NSNumber numberWithContentIdentifierType:kSCHContentItemContentIdentifierTypesISBN13] forKey:kSCHLibreAccessWebServiceContentIdentifierType];
    [ret setObject:[NSNumber numberWithDRMQualifier:drmQualifer] forKey:kSCHLibreAccessWebServiceDRMQualifier];
    [ret setObject:@"XPS" forKey:kSCHLibreAccessWebServiceFormat];
    [ret setObject:@"1" forKey:kSCHLibreAccessWebServiceVersion];    
    [ret setObject:profileList forKey:kSCHLibreAccessWebServiceProfileList];
    [ret setObject:orderList forKey:kSCHLibreAccessWebServiceOrderList];        
    [ret setObject:dateNow forKey:kSCHLibreAccessWebServiceLastModified];
    [ret setObject:[NSNumber numberWithBool:NO] forKey:kSCHLibreAccessWebServiceDefaultAssignment];
    
    return(ret);    
}

- (BOOL)populateBook:(NSString *)xpsFilePath profileIDs:(NSArray *)profileIDs
{
    BOOL ret = YES;
    NSError *error = nil;
    NSString *title = nil;
    NSString *author = nil;
    NSString *ISBN = nil;
    unsigned long long fileSize = 0;    
    SCHXPSProvider *xpsProvider = [[SCHXPSProvider alloc] initWithBookIdentifier:nil 
                                                                         xpsPath:xpsFilePath];
    
    if(xpsProvider != nil) {
        CXMLDocument *doc = [[CXMLDocument alloc] initWithData:[xpsProvider dataForComponentAtPath:KNFBXPSKNFBMetadataFile] 
                                                       options:0 
                                                         error:&error];
        NSArray *nodes = nil;
        
        if (error == nil) {
            nodes = [doc nodesForXPath:@"//Title" error:&error];
            if (error == nil) {		
                for (CXMLElement *node in nodes) {
                    title = [[node attributeForName:@"Main"] stringValue];
                }	
            }
            nodes = [doc nodesForXPath:@"//Contributor" error:&error];
            if (error == nil) {		
                for (CXMLElement *node in nodes) {
                    author = [[node attributeForName:@"Author"] stringValue];
                }	
            }		
            nodes = [doc nodesForXPath:@"//Identifier" error:&error];
            if (error == nil) {		
                for (CXMLElement *node in nodes) {
                    ISBN = [[node attributeForName:@"ISBN"] stringValue];
                }	
            }		
        }
        [doc release], doc = nil;

        // check we don't already have the book
        SCHAppBook *appBook = [[SCHBookManager sharedBookManager] bookWithIdentifier:[[[SCHBookIdentifier alloc] initWithISBN:ISBN 
                                                                                                                 DRMQualifier:[NSNumber numberWithDRMQualifier:kSCHDRMQualifiersFullNoDRM]] autorelease]
                                                              inManagedObjectContext:self.managedObjectContext];
        
        if (appBook == nil) {
            fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:xpsFilePath 
                                                                        error:&error].fileSize;
            
            if (error != nil) {
                NSLog(@"Error reading XPS file size: %@, %@", error, [error userInfo]);
            }
            
            NSDictionary *book = [self contentMetaDataItemWith:ISBN
                                                         title:title
                                                        author:author
                                                    pageNumber:[xpsProvider pageCount]
                                                      fileSize:fileSize
                                                   drmQualifer:kSCHDRMQualifiersFullNoDRM
                                                      coverURL:nil
                                                    contentURL:nil
                                                      enhanced:[xpsProvider componentExistsAtPath:KNFBXPSStoryInteractionsMetadataFile]];
            
            [self.contentSyncComponent addUserContentItem:[self userContentItemWith:[book objectForKey:kSCHLibreAccessWebServiceContentIdentifier] 
                                                                        drmQualifer:[[book objectForKey:kSCHLibreAccessWebServiceDRMQualifier] DRMQualifierValue]                                                    
                                                                         profileIDs:profileIDs]];
            SCHContentMetadataItem *newContentMetadataItem = [self.bookshelfSyncComponent addContentMetadataItem:book];
            newContentMetadataItem.FileName = [xpsFilePath lastPathComponent];
            
            // extract the cover image
            NSData *imageData = [xpsProvider coverThumbData];
            if (imageData != nil) {   
                NSData *pngData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
                if (![pngData writeToFile:[newContentMetadataItem.AppBook coverImagePath] atomically:YES]) {
                    NSLog(@"Error occurred whilst trying to write imported book cover image to disk");
                }
            }
            // we need to unlock the file from XPS before we can move it
            [xpsProvider release], xpsProvider = nil;
            
            // move the XPS file
            [[NSFileManager defaultManager] moveItemAtPath:xpsFilePath 
                                                    toPath:[newContentMetadataItem.AppBook xpsPath] 
                                                     error:&error];        
            if (error != nil) {
                NSLog(@"Error moving XPS file: %@, %@", error, [error userInfo]);
            }
            
            [newContentMetadataItem.AppBook setXPSExists:[NSNumber numberWithBool:YES]];
            [newContentMetadataItem.AppBook setBookCoverExists:[NSNumber numberWithBool:YES]];
            [newContentMetadataItem.AppBook setForcedProcessing:YES];
            newContentMetadataItem.AppBook.State = [NSNumber numberWithInt:SCHBookProcessingStateReadyForLicenseAcquisition];
        }
        else {
            ret = NO;
            [xpsProvider release], xpsProvider = nil;
        }
    }
    
    return(ret);
}

@end
