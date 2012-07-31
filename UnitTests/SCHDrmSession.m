//
//  SCHDrmSession.m
//  Scholastic
//
//  Created by Matt Farrugia on 31/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHDrmSession.h"

@implementation SCHDrmSession

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // ignore
}

@end

@implementation SCHDrmRegistrationSession : SCHDrmSession
@end


@implementation SCHDrmLicenseAcquisitionSession
@end

@implementation SCHDrmDecryptionSession

- (BOOL)bindToLicense
{
    return YES;
}

- (BOOL)reportReading
{
    return YES;
}

- (BOOL)decryptData:(NSData *)data
{
    return YES;
}

@end