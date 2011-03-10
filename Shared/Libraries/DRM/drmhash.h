/**@@@+++@@@@******************************************************************
**
** Microsoft PlayReady
** Copyright (c) Microsoft Corporation. All rights reserved.
**
***@@@---@@@@******************************************************************
*/


#ifndef __DRMHASH_H__
#define __DRMHASH_H__

#include "drmsha1.h"
#include "drmsha256.h"

ENTER_PK_NAMESPACE;


/*
** Supported hash algorithms
*/
typedef enum __tageDRM_SHA_SUPPORTED_ALGORITHMS
{
    eDRM_SHA_1   = 0,
    eDRM_SHA_256 = 1
} eDRM_SHA_SUPPORTED_ALGORITHMS;


#define DRM_SHA_DIGEST_LEN_MAX    max( DRM_SHA1_DIGEST_LEN, SHA256_DIGEST_SIZE_IN_BYTES )
#define DRM_SHA_BLOCK_SIZE_MAX    max( DRM_SHA1_BLOCK_SIZE, SHA256_BLOCK_SIZE_IN_BYTES )
#define DRM_SHA_CONTEXT_SIZE_MAX  max( SIZEOF( DRM_SHA1_CONTEXT ), SIZEOF( DRM_SHA256_Context ) )


typedef struct __tagDRM_SHA_CONTEXT
{
    DRM_BOOL                      fInitialized;
    eDRM_SHA_SUPPORTED_ALGORITHMS eAlgorithm;
    union _tagContext
    {
        DRM_SHA1_CONTEXT    sha1Context;
        DRM_SHA256_Context  sha256Context;
    } context;     
} DRM_SHA_CONTEXT;

#define DRM_SHA_CONTEXT_DEFAULT { FALSE, eDRM_SHA_1, { 0 } }


DRM_API DRM_RESULT DRM_CALL DRM_SHA_Init(
    __inout_ecount( 1 ) DRM_SHA_CONTEXT               *f_pShaContext,
    __in                eDRM_SHA_SUPPORTED_ALGORITHMS  f_eAlgorithm ); 


DRM_API DRM_RESULT DRM_CALL DRM_SHA_Update(
    __in_bcount( f_cbData ) const DRM_BYTE         *f_pbData,
    __in                          DRM_DWORD         f_cbData,
    __inout_ecount( 1 )           DRM_SHA_CONTEXT  *f_pShaContext );


DRM_API DRM_RESULT DRM_CALL DRM_SHA_UpdateOffset(
    __in_bcount( f_cbData ) const DRM_BYTE         *f_pbData,
    __in                          DRM_DWORD         f_ibData,
    __in                          DRM_DWORD         f_cbData,
    __inout_ecount( 1 )           DRM_SHA_CONTEXT  *f_pShaContext );
    
        
DRM_API DRM_RESULT DRM_CALL DRM_SHA_Finalize(
    __in_ecount( 1 )            DRM_SHA_CONTEXT *f_pShaContext,
    __in                        DRM_DWORD        f_cbDigest,
    __inout_bcount( f_cbDigest) DRM_BYTE        *f_pbDigest );
            
            
EXIT_PK_NAMESPACE;

#endif /* __DRMHASH_H__ */
