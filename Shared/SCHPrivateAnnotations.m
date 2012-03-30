// 
//  SCHPrivateAnnotations.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHPrivateAnnotations.h"

#import "SCHAnnotationsContentItem.h"
#import "SCHBookmark.h"
#import "SCHHighlight.h"
#import "SCHLastPage.h"
#import "SCHRating.h"
#import "SCHNote.h"

// Constants
NSString * const kSCHPrivateAnnotations = @"SCHPrivateAnnotations";

@implementation SCHPrivateAnnotations 

@dynamic LastPage;
@dynamic rating;
@dynamic AnnotationsContentItem;
@dynamic Bookmarks;
@dynamic Highlights;
@dynamic Notes;

@end
