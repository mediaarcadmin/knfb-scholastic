//
//  SCHBookIdentifier.m
//  Scholastic
//
//  Created by Neil Gall on 30/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookIdentifier.h"
#import "SCHLibreAccessConstants.h"

// Constants
NSString * const kSCHBookIdentifierBookIdentifier = @"BookIdentifier";

@implementation SCHBookIdentifier

@synthesize isbn;
@synthesize DRMQualifier;

- (void)dealloc
{
    [isbn release], isbn = nil;
    [DRMQualifier release], DRMQualifier = nil;
    [super dealloc];
}

- (id)initWithISBN:(NSString *)aIsbn DRMQualifier:(NSNumber *)aDRMQualifier
{
    if ((self = [super init])) {
        if (aIsbn != (id)[NSNull null] &&
            aDRMQualifier != (id)[NSNull null] &&
            [[aIsbn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            [aDRMQualifier isValidDRMQualifierValue] == YES) {
            isbn = [aIsbn copy];
            DRMQualifier = [aDRMQualifier copy];
        } else {
            [self release], self = nil;            
        }
    }
    return self;
}

// creates bookIdentifier objects with a dictionary containing ContentIdentifer 
// and DRM Qualifier such as ContentMetadataItem's from Core Data or the web service
- (id)initWithObject:(NSDictionary *)object
{
    NSString *aIsbn = [object objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
    NSNumber *aDRMQualifier = [object objectForKey:kSCHLibreAccessWebServiceDRMQualifier];
    
    return [self initWithISBN:aIsbn DRMQualifier:aDRMQualifier];
}

- (id)initWithEncodedString:(NSString *)string
{
    NSArray *parts = [string componentsSeparatedByString:@"§"];
    if ([parts count] == 2) {
        return [self initWithISBN:[parts objectAtIndex:0]
                     DRMQualifier:[NSNumber numberWithInteger:[[parts objectAtIndex:1] integerValue]]];
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    SCHBookIdentifier *copy = [[SCHBookIdentifier alloc] initWithISBN:self.isbn
                                                         DRMQualifier:self.DRMQualifier];
    return copy;
}

- (NSString *)encodeAsString
{
    return [NSString stringWithFormat:@"%@§%@", self.isbn, self.DRMQualifier];
}

- (NSUInteger)hash
{
    return [self.isbn hash] * 7 + [self.DRMQualifier integerValue];
}

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[SCHBookIdentifier class]]) {
        return NO;
    }
    SCHBookIdentifier *other = (SCHBookIdentifier *)object;
    return ([self.DRMQualifier isEqual:other.DRMQualifier] && [self.isbn isEqual:other.isbn]);
}

- (NSComparisonResult)compare:(SCHBookIdentifier *)aBookIdentifier
{
    NSParameterAssert(aBookIdentifier);
    
    NSComparisonResult ret = [self.isbn compare:aBookIdentifier.isbn];
    
    if (ret == NSOrderedSame) {
        ret = [self.DRMQualifier compare:aBookIdentifier.DRMQualifier];
    }
    
    return ret;
}

- (NSString *)description
{
    NSString *drm = nil;
    switch ([self.DRMQualifier integerValue]) {
        case kSCHDRMQualifiersNone: drm = @"None"; break;
        case kSCHDRMQualifiersFullNoDRM: drm = @"FullNoDRM"; break;
        case kSCHDRMQualifiersFullWithDRM: drm = @"FullWithDRM"; break;
        case kSCHDRMQualifiersSample: drm = @"Sample"; break;
    }
    return [NSString stringWithFormat:@"%@-%@", self.isbn, drm];
}

@end
