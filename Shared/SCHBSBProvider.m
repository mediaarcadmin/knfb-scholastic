//
//  SCHBSBProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBProvider.h"

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

- (NSUInteger)pageCount
{
    return 10;
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

#pragma mark - EucEPubDataProvider

- (NSData *)dataForComponentAtPath:(NSString *)path
{
    return nil;
}

- (NSURL *)fileURLForPath:(NSString *)path
{
    return nil;
}

@end
