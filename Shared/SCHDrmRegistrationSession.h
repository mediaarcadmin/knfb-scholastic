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

/*
@protocol SSCHDrmLicAcquisitionSessionDelegate;

@interface SCHDrmLicAcquisitionSession : SCHDrmSession   
{
	struct SCHDrmIVars *drmIVars; 
}

@property (nonatomic, retain) id<SSCHDrmLicAcquisitionSessionDelegate> delegate;
@property (nonatomic, retain) NSString* bookID;

- (void)acquireLicense:(NSString *)token;

@end
 
 */
