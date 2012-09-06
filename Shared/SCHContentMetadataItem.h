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
@class SCHBooksAssignment;

// Constants
extern NSString * const kSCHContentMetadataItem;

@interface SCHContentMetadataItem : SCHContentItem {

}

@property (nonatomic, retain) NSString * appealsToHigh;
@property (nonatomic, retain) NSString * appealsToLow;
@property (nonatomic, retain) NSString * Author;
@property (nonatomic, retain) NSNumber * AverageRating;
@property (nonatomic, retain) NSString * ContentURL;
@property (nonatomic, retain) NSString * CoverURL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * eBookLexileLevel;
@property (nonatomic, retain) NSNumber * Enhanced;
@property (nonatomic, retain) NSString * FileName;
@property (nonatomic, retain) NSNumber * FileSize;
@property (nonatomic, retain) NSString * FormatAuthorString;
@property (nonatomic, retain) NSString * formatTitleString;
@property (nonatomic, retain) NSString * guidedReadingLevel;
@property (nonatomic, retain) NSString * misc2;
@property (nonatomic, retain) NSString * misc3;
@property (nonatomic, retain) NSString * misc4;
@property (nonatomic, retain) NSString * misc5;
@property (nonatomic, retain) NSNumber * numVotes;
@property (nonatomic, retain) NSNumber * PageNumber;
@property (nonatomic, retain) NSString * readingLevel;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Version;

@property (nonatomic, retain) SCHAppBook * AppBook;
@property (nonatomic, retain) NSSet* eReaderCategories;

@property (nonatomic, readonly) NSSet *AnnotationsContentItem;
@property (nonatomic, readonly) SCHBooksAssignment *booksAssignment;

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID;
- (void)deleteAllFiles;
- (void)deleteBookPackageFile;
- (void)deleteCoverFile;

@end
