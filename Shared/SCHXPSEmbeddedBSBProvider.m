//
//  SCHXPSEmbeddedBSBProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 28/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHXPSEmbeddedBSBProvider.h"
#import "SCHBSBManifest.h"

@interface SCHXPSEmbeddedBSBProvider()

@property (nonatomic, retain) SCHBSBManifest *manifest;

@end

@implementation SCHXPSEmbeddedBSBProvider

@synthesize manifest;

- (void)dealloc
{
    [manifest release], manifest = nil;
    [super dealloc];
}

- (BOOL)containsFixedRepresentation
{
    return NO;
}

- (BOOL)containsFlowedRepresentation
{
    return YES;
}

#pragma mark - SCHBSBContentsProvider

- (SCHBSBManifest *)manifest
{
    if (!manifest) {
        NSData *manifestData = [self dataForComponentAtPath:@"/Documents/1/Other/KNFB/Branching/manifest.xml"];
        manifest = [[SCHBSBManifest alloc] initWithXMLData:manifestData];
    }
    
    return manifest;
}

- (NSData *)dataForBSBComponentAtPath:(NSString *)path
{
    return [self dataForComponentAtPath:[@"/Documents/1/Other/KNFB/Branching/" stringByAppendingPathComponent:path]];
}

@end
