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
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *connectionData;


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

- (id)initWithBook:(NSString*)isbn;
- (void)acquireLicense:(NSString *)token bookID:(NSString*)isbn;

@end

@interface SCHDrmDecryptionSession : SCHDrmSession   
{
	struct SCHDrmIVars *drmIVars; 
}


@end
 
 
