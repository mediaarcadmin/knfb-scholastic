//
//  SCHBSBProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBProvider.h"
#import "SCHBSBConstants.h"
#import "SCHBSBManifest.h"

NSString * const SCHBSBManifestFile = @"/manifest.xml";

@interface SCHBSBProvider()

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;
@property (nonatomic, retain) SCHBSBManifest *manifest;

@end

@implementation SCHBSBProvider

@synthesize bookIdentifier;
@synthesize manifest;

- (void)dealloc
{
    [bookIdentifier release], bookIdentifier = nil;
    [manifest release], manifest = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier path:(NSString *)bsbPath error:(NSError **)error
{
    if ((self = [super initWithZipFileAtPath:bsbPath])) {
        
    }
    
    return self;
}

#pragma mark - SCHBookPackageProvider

- (BOOL)componentExistsAtPath:(NSString *)path
{
    NSData *componentData = [self dataForComponentAtPath:path];
    
    return (componentData != nil);
}

- (BOOL)isEncrypted
{
    return NO;
}

- (BOOL)isValid
{
    return [self componentExistsAtPath:SCHBSBManifestFile];
}

- (BOOL)decryptionIsAvailable
{
    return NO;
}

- (BOOL)containsFixedRepresentation
{
    return NO;
}

- (BOOL)containsFlowedRepresentation
{
    return YES;
}

- (void)resetDrmDecrypter
{
    // noop
}

- (void)reportReadingIfRequired
{
    // noop
}

- (UIImage *)thumbnailForPage:(NSInteger)pageNumber
{
    return nil;
}

- (NSData *)dataForComponentAtPath:(NSString *)path
{
    @synchronized(self) {
        return [super dataForComponentAtPath:path];
    }
}

- (NSURL *)fileURLForPath:(NSString *)path
{
    @synchronized(self) {
        return [super fileURLForPath:path];
    }
}

#pragma mark - SCHBSBContentsProvider

- (SCHBSBManifest *)manifest
{
    if (!manifest) {
        NSData *manifestData = [self dataForComponentAtPath:@"manifest.xml"];
        manifest = [[SCHBSBManifest alloc] initWithXMLData:manifestData];
    }
    
    return manifest;
}

- (NSData *)dataForBSBComponentAtPath:(NSString *)path
{
    return [self dataForComponentAtPath:path];
}


@end
