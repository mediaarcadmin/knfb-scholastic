//
//  SCHBookStoryInteractions+XPS.m
//  Scholastic
//
//  Created by Neil Gall on 03/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHBookStoryInteractions+XPS.h"
#import "SCHStoryInteractionParser.h"
#import "SCHStoryInteractionParser.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"

@implementation SCHBookStoryInteractions (XPS)

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider oddPagesOnLeft:(BOOL)oddPagesOnLeft
{
    // get the raw array of stories from the parser
    NSData *xml = [xpsProvider dataForComponentAtPath:KNFBXPSStoryInteractionsMetadataFile];
    SCHStoryInteractionParser *parser = [[SCHStoryInteractionParser alloc] init];
    self = [self initWithStoryInteractions:[parser parseStoryInteractionsFromData:xml] oddPagesOnLeft:oddPagesOnLeft];
    [parser release];
    return self;
}

@end
