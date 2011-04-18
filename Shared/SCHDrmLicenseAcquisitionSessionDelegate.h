//
//  SCHDrmLicenseAcquisitionSessionDelegate.h
//  Scholastic
//
//  Created by Arnold Chien on 4/13/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHDrmLicenseAcquisitionSession;

@protocol SCHDrmLicenseAcquisitionSessionDelegate

- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didComplete:(id)result;
- (void)licenseAcquisitionSession:(SCHDrmLicenseAcquisitionSession *)licenseAcquisitionSession didFailWithError:(NSError *)error;

@end