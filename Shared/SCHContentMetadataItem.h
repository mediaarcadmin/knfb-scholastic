//
//  SCHContentMetadataItem.h
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SCHContentItem.h"

@class SCHAppBook;
@class SCHeReaderCategories;
@class SCHBookIdentifier;
@class SCHUserContentItem;

// Constants
extern NSString * const kSCHContentMetadataItem;

@interface SCHContentMetadataItem : SCHContentItem {

}

@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Version;
@property (nonatomic, retain) NSNumber * Enhanced;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSString * FileName;
@property (nonatomic, retain) SCHAppBook * AppBook;
@property (nonatomic, retain) NSSet* eReaderCategories;
@property (nonatomic, retain) NSString * FormatAuthorString;
@property (nonatomic, retain) NSString * formatTitleString;
@property (nonatomic, retain) NSNumber * AverageRating;

@property (nonatomic, readonly) NSSet *AnnotationsContentItem;
@property (nonatomic, readonly) SCHUserContentItem *UserContentItem;

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID;
- (void)deleteAllFiles;
- (void)deleteBookPackageFile;
- (void)deleteCoverFile;

@end
