//
//  NSFileManager+Extensions.m
//  Scholastic
//
//  Created by John Eddie on 01/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSFileManager+Extensions.h"

@implementation NSFileManager (NSFileManagerExtensions)

- (BOOL)BITfileSystemHasBytesAvailable:(unsigned long long)sizeInBytes
{
    BOOL ret = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = ([paths count] > 0 ? [paths objectAtIndex:0] : nil);            
    
    if (docDirectory != nil) {
        NSDictionary *attributesOfFileSystem = [self attributesOfFileSystemForPath:docDirectory error:nil];
        
        unsigned long long freeSize = [[attributesOfFileSystem objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        ret = (sizeInBytes <= freeSize);
    }
    
    return ret;
}

#pragma mark - Class methods

+ (NSString *)BITtemporaryDirectoryIfExistsOrCreated
{
    NSString *temporaryDirectory = NSTemporaryDirectory();
    
    if (temporaryDirectory != nil) {        
        NSFileManager *localManager = [[[NSFileManager alloc] init] autorelease];
        NSError *error = nil;
        
        if ([localManager fileExistsAtPath:temporaryDirectory] == NO) {
            if ([localManager createDirectoryAtPath:temporaryDirectory 
                        withIntermediateDirectories:YES 
                                         attributes:nil 
                                              error:&error] == NO) {
                NSLog(@"Unable to create temporary directory with error %@ : %@", error, [error userInfo]);
                temporaryDirectory = nil;
            }            
        }
    }
    
    return temporaryDirectory;
}

@end
