//
//  SCHDrmRegistrationSession.h
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDrmSession.h"

@protocol SCHDrmRegistrationSessionDelegate;

@interface SCHDrmRegistrationSession : SCHDrmSession   
{
	struct SCHDrmIVars *drmIVars;  
}

@property (nonatomic, retain) id<SCHDrmRegistrationSessionDelegate> delegate;
@property (nonatomic, assign) BOOL isJoining;


- (void)registerDevice:(NSString *)token;
- (void)deregisterDevice:(NSString *)token;

@end


@protocol SCHDrmLicenseAcquisitionSessionDelegate;

@interface SCHDrmLicenseAcquisitionSession : SCHDrmSession   
{
	struct SCHDrmIVars *drmIVars; 
}

@property (nonatomic, retain) id<SCHDrmLicenseAcquisitionSessionDelegate> delegate;
@property (nonatomic, retain) NSString* bookID;
@property (nonatomic, retain) NSString* boundBookID;

- (void)acquireLicense:(NSString *)token;
//- (void)acknowledgeLicense;

@end
 
 
