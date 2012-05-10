//
//  SCHBSBProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBProvider.h"
#import "SCHBSBConstants.h"

NSString * const SCHBSBManifestFile = @"/manifest.xml";

@interface SCHBSBProvider()

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

@end

@implementation SCHBSBProvider

@synthesize bookIdentifier;

- (void)dealloc
{
    [bookIdentifier release], bookIdentifier = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier path:(NSString *)bsbPath
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

@end
