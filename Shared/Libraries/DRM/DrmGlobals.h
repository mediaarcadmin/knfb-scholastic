//
//  DrmGlobals.h
//  libPlayReadyPK
//
//  Created by Arnold Chien on 4/29/10.
//  Copyright 2010 Kurzweil Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"
#include "drmmanager.h"

#define HDS_STORE_FILE  L".\\playready.hds"

@interface DrmGlobals : NSObject {
	// The path to the device cert and other assets.
	// For now, just the resource path.
	DRM_WCHAR* _rawDrmPath; 
	DRM_STRING drmPath;
	
	// Data store.
	DRM_WCHAR* _dataStore;
	DRM_STRING dataStore;
	
	// License rights.  For now just Read.
	DRM_WCHAR* _readRight;
	DRM_STRING readRight;
	
	// Keychain items.
	KeychainItemWrapper* devKeyEncryptItem;
	KeychainItemWrapper* devKeySignItem;
	KeychainItemWrapper* devCertItem;
	
}

@property (nonatomic, assign) DRM_STRING drmPath;
@property (nonatomic, assign) DRM_STRING dataStore;
@property (nonatomic, assign) DRM_STRING readRight;
@property (nonatomic, retain) KeychainItemWrapper* devDecryptKeyItem;
@property (nonatomic, retain) KeychainItemWrapper* devSignKeyItem;


+ (DrmGlobals*)getDrmGlobals;


@end

