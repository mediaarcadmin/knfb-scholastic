//
//  NSFileManager+DoNotBackupExtendedAttribute.m
//  Scholastic
//
//  Created by John Eddie on 20/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSFileManager+DoNotBackupExtendedAttribute.h"

#import <libEucalyptus/THUIDeviceAdditions.h>
#include <sys/xattr.h>

// See http://developer.apple.com/library/ios/#qa/qa1719/_index.html

@implementation NSFileManager (DoNotBackupExtendedAttribute)

- (BOOL)BITsetSkipBackupAttributeToItemAtFilePath:(NSString *)filePath
{
    BOOL ret = NO;

    if ([[filePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
        [self fileExistsAtPath:filePath] == YES) {
        if([[UIDevice currentDevice] compareSystemVersion:@"5.1"] >= NSOrderedSame) {
            ret = [self BITaddSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:filePath]];
        } else {
            ret = [self BITaddSkipBackupAttributeToItemAtFilePath:filePath];
        }
    }
    
    return ret;
}

// only use with iOS 5.1 or above
- (BOOL)BITaddSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if (success == NO) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }

    return success;
}

// Setting this on iOS < 5.0 has no effect 
- (BOOL)BITaddSkipBackupAttributeToItemAtFilePath:(NSString *)filePath
{
    BOOL ret = NO;    
    const char *filePathAsChar = [filePath fileSystemRepresentation];
    static const char *attributeName = "com.apple.MobileBackup";
    u_int8_t attributeValue = 1;
    
    int result = setxattr(filePathAsChar, attributeName, &attributeValue, sizeof(attributeValue), 0, 0);
    if (result == -1) {
        NSLog(@"Error excluding %@ from backup %d '%s'", filePath, errno, strerror(errno));
    } else {
        ret = (result == 0);
    }
    
    return ret;
}

@end