//
//  ZipArchive.mm
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"
#import "SCHUserDefaults.h"


@interface ZipArchive (Private)

-(void) OutputErrorMessage:(NSString*) msg;
-(BOOL) OverWrite:(NSString*) file;
-(void) DoUnzipProgress:(uLong)myCurrentFileIndex;
-(NSDate*) Date1980;
@end



@implementation ZipArchive
@synthesize delegate = _delegate;

-(id) init
{
    if( (self=[super init]))
    {
        _totalFileCount = 0;
    }
    return self;
}

-(void) dealloc
{
    [super dealloc];
}


-(BOOL) UnzipOpenFile:(NSString*) zipFile
{
    _unzFile = unzOpen( (const char*)[zipFile UTF8String] );
    if( _unzFile )
    {
        unz_global_info  globalInfo = {0};
        if( unzGetGlobalInfo(_unzFile, &globalInfo )==UNZ_OK )
        {
            _totalFileCount = globalInfo.number_entry;
        }
    }
    return _unzFile!=NULL;
}

-(BOOL) UnzipOpenFile:(NSString*) zipFile Password:(NSString*) password
{
    _password = password;
    return [self UnzipOpenFile:zipFile];
}

-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite
{
    BOOL success = YES;
    int ret = unzGoToFirstFile( _unzFile );
    unsigned char           buffer[4096] = {0};
    NSFileManager* fman = [[NSFileManager alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];

    if( ret!=UNZ_OK )
    {
        [self OutputErrorMessage:@"Failed"];
    }
    
    uLong kFileCount = 0;
    uLong uncompressedFileSize = 0;
    
    do{
        
        if (kFileCount % 100 == 0) {
            // space check
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDirectory = ([paths count] > 0 ? [paths objectAtIndex:0] : nil);            
            
            NSDictionary* fsAttr = [fman attributesOfFileSystemForPath:docDirectory error:NULL];
            
            unsigned long long freeSize = [(NSNumber*)[fsAttr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
            
//            NSLog(@"Checking space: %llu", freeSize);
            
            if (freeSize <= 10485760) {
                [self OutputErrorMessage:@"Not enough free space."];
                success = NO;
                unzCloseCurrentFile( _unzFile );
                break;
            }
        }
        
        if( [_password length]==0 )
            ret = unzOpenCurrentFile( _unzFile );
        else
            ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
        if( ret!=UNZ_OK )
        {
            [self OutputErrorMessage:@"Error occurs"];
            success = NO;
            break;
        }
        // reading data and write to file
        int read ;
        unz_file_info   fileInfo ={0};
        ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
        if( ret!=UNZ_OK )
        {
            [self OutputErrorMessage:@"Error occurs while getting file info"];
            success = NO;
            unzCloseCurrentFile( _unzFile );
            break;
        }
        char* filename = (char*) malloc( fileInfo.size_filename +1 );
        unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
        filename[fileInfo.size_filename] = '\0';
        
        // check if it contains directory
		NSString * strPath = [NSString  stringWithCString:filename encoding:NSUTF8StringEncoding];
        BOOL isDirectory = NO;
        if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
            isDirectory = YES;
        free( filename );
        if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
        {// contains a path
            strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        }
        NSString* fullPath = [path stringByAppendingPathComponent:strPath];
        
        if( isDirectory )
            [fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
        else
            [fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
        if( [fman fileExistsAtPath:fullPath] && !isDirectory && !overwrite )
        {
            if( ![self OverWrite:fullPath] )
            {
                unzCloseCurrentFile( _unzFile );
                ret = unzGoToNextFile( _unzFile );
                continue;
            }
        }
        FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
        while( fp )
        {
            read=unzReadCurrentFile(_unzFile, buffer, 4096);
            if( read > 0 )
            {
                int files = fwrite(buffer, read, 1, fp );
                
                // if the file is not successfully written, we're out of file space
                if (files != 1) {
                    success = NO;
                    unzCloseCurrentFile( _unzFile );
                    break;
                }
            }
            else if( read<0 )
            {
                [self OutputErrorMessage:@"Failed to reading zip file"];
                break;
            }
            else 
                break;                          
        }
        if( fp )
        {
            fclose( fp );
            // set the orignal datetime property
            NSDate* orgDate = nil;
            
            //{{ thanks to brad.eaton for the solution
            NSDateComponents *dc = [[NSDateComponents alloc] init];
            
            dc.second = fileInfo.tmu_date.tm_sec;
            dc.minute = fileInfo.tmu_date.tm_min;
            dc.hour = fileInfo.tmu_date.tm_hour;
            dc.day = fileInfo.tmu_date.tm_mday;
            dc.month = fileInfo.tmu_date.tm_mon+1;
            dc.year = fileInfo.tmu_date.tm_year;
            
            orgDate = [gregorian dateFromComponents:dc];
            [dc release];
            //}}
            
            
            NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
            if( attr )
            {
                //              [attr  setValue:orgDate forKey:NSFileCreationDate];
                if( ![fman setAttributes:attr ofItemAtPath:fullPath error:nil] )
                {
                    // cann't set attributes 
                    NSLog(@"Failed to set attributes");
                }
                
            }
            
            kFileCount++;
            [self DoUnzipProgress:kFileCount];
            uncompressedFileSize += fileInfo.uncompressed_size;
        }
        unzCloseCurrentFile( _unzFile );
        ret = unzGoToNextFile( _unzFile );
    }while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );

    [fman release];
    [gregorian release];

    if (success == YES)   {
        NSInteger totalUncompressedFileSize = [[NSUserDefaults standardUserDefaults] integerForKey:kSCHDictionaryTotalUncompressedFileSize];
        totalUncompressedFileSize += uncompressedFileSize;
        [[NSUserDefaults standardUserDefaults] setInteger:totalUncompressedFileSize forKey:kSCHDictionaryTotalUncompressedFileSize];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return success;
}

-(BOOL) UnzipCloseFile
{
    _totalFileCount = 0;
    _password = nil;
    if( _unzFile )
        return unzClose( _unzFile )==UNZ_OK;
    return YES;
}

#pragma mark wrapper for delegate
-(void) OutputErrorMessage:(NSString*) msg
{
    if( _delegate && [_delegate respondsToSelector:@selector(ErrorMessage)] )
        [_delegate ErrorMessage:msg];
}

-(BOOL) OverWrite:(NSString*) file
{
    if( _delegate && [_delegate respondsToSelector:@selector(OverWriteOperation)] )
        return [_delegate OverWriteOperation:file];
    return YES;
}

-(void) DoUnzipProgress:(uLong)myCurrentFileIndex
{
    if( _delegate && [_delegate respondsToSelector:@selector(UnzipProgress:total:)] )
        [_delegate UnzipProgress:myCurrentFileIndex total:_totalFileCount];
}

#pragma mark get NSDate object for 1980-01-01
-(NSDate*) Date1980
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    [comps setMonth:1];
    [comps setYear:1980];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    
    [comps release];
    [gregorian release];
    return date;
}

@end