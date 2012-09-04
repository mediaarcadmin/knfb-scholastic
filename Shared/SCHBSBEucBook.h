//
//  SCHBSBEucBook.h
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#if !BRANCHING_STORIES_DISABLED
#import <libEucalyptus/EucBook.h>
#import "SCHEucBookmarkPointTranslation.h"
#import "SCHBSBEucBookDelegate.h"

@class EucBookIndex, EucBookNavPoint, EucBookPageIndexPoint, EucBookPageIndexPointRange;
@class EucCSSIntermediateDocument;
@class SCHBookIdentifier;

@interface SCHBSBEucBook : NSObject <EucBook, SCHEucBookmarkPointTranslation>

@property (nonatomic, assign) id <SCHBSBEucBookDelegate> delegate;

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc;
- (EucCSSIntermediateDocument *)intermediateDocumentForIndexPoint:(EucBookPageIndexPoint *)indexPoint 
                                                      pageOptions:(NSDictionary *)pageOptions;
- (NSUInteger)sourceCount;
- (void)resetBookToStart:(BOOL)clearProperties;

@end
#endif