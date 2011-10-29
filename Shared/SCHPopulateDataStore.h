//
//  SCHPopulateDataStore.h
//  Scholastic
//
//  Created by John S. Eddie on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHProfileSyncComponent;
@class SCHContentSyncComponent;
@class SCHBookshelfSyncComponent;
@class SCHAnnotationSyncComponent;
@class SCHReadingStatsSyncComponent;
@class SCHSettingsSyncComponent;

@interface SCHPopulateDataStore : NSObject
{    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) SCHProfileSyncComponent *profileSyncComponent; 
@property (retain, nonatomic) SCHContentSyncComponent *contentSyncComponent;
@property (retain, nonatomic) SCHBookshelfSyncComponent *bookshelfSyncComponent;
@property (retain, nonatomic) SCHAnnotationSyncComponent *annotationSyncComponent;
@property (retain, nonatomic) SCHReadingStatsSyncComponent *readingStatsSyncComponent;
@property (retain, nonatomic) SCHSettingsSyncComponent *settingsSyncComponent;

- (NSUInteger)populateFromImport;

// for populating Sample Store
- (void)populateTestSampleStore;
- (void)populateSampleStore;
- (BOOL)populateSampleStoreFromManifestEntries:(NSArray *)entries;
- (void)setAppStateForSample;

@end
