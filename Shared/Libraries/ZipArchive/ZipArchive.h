//
//  ZipArchive.h
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//
// History: 
//    09-11-2008 version 1.0    release
//    10-18-2009 version 1.1    support password protected zip files
//    10-21-2009 version 1.2    fix date bug
//
// (BitWink: removed zipping code - only need unzip)
// (BitWink: added progress delegate from ZipArchive wiki)

#import <UIKit/UIKit.h>

#include "minizip/unzip.h"


@protocol ZipArchiveDelegate <NSObject>
@optional
-(void) ErrorMessage:(NSString*) msg;
-(BOOL) OverWriteOperation:(NSString*) file;
-(void) UnzipProgress:(uLong)myCurrentFileIndex total:(uLong)myTotalFileCount;
@end


@interface ZipArchive : NSObject {
@private
    unzFile         _unzFile;
    
    NSString*   _password;
    uLong _totalFileCount;
    id<ZipArchiveDelegate>                  _delegate;
}

@property (nonatomic, assign) id<ZipArchiveDelegate> delegate;

-(BOOL) UnzipOpenFile:(NSString*) zipFile;
-(BOOL) UnzipOpenFile:(NSString*) zipFile Password:(NSString*) password;
-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
-(NSMutableArray *) getZipFileContents;
-(BOOL) UnzipCloseFile;
@end