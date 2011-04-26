//
//  SCHLicenseAcquisitionOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 14/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookOperation.h"
#import "SCHDrmRegistrationSession.h"
#import "SCHDrmLicenseAcquisitionSessionDelegate.h"

@interface SCHLicenseAcquisitionOperation : SCHBookOperation<SCHDrmLicenseAcquisitionSessionDelegate> {
    
}

@property (nonatomic, retain) SCHDrmLicenseAcquisitionSession* licenseAcquisitionSession;

@end