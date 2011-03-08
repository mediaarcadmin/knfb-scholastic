//
//  SCHContentMetadataItem+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHContentMetadataItem+Extensions.h"

#import "SCHAnnotationsContentItem+Extensions.h"

static NSString * const kSCHContentMetadataItemAnnotationsContentItem = @"AnnotationsContentItem";
static NSString * const kSCHContentMetadataItemAnnotationsListProfileID = @"AnnotationsList.ProfileID";

@implementation SCHContentMetadataItem (SCHContentMetadataItemExtensions)

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID
{
	NSMutableArray *annotations = [NSMutableArray array];
	
	for (SCHAnnotationsContentItem *annotationsContentItem in [self valueForKey:kSCHContentMetadataItemAnnotationsContentItem]) {
		if ([profileID isEqualToNumber:[annotationsContentItem valueForKeyPath:kSCHContentMetadataItemAnnotationsListProfileID]] == YES) {
			[annotations addObject:annotationsContentItem];
		}
	}
	
	return(annotations);	
}

- (void)clearURLs
{
	self.CoverURL == nil;
	self.ContentURL == nil;
}

- (BOOL)haveURLs
{
	return(!(self.CoverURL == nil || self.ContentURL == nil));
}

@end
