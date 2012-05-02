//
//  NSFileManager+Extensions.h
//  Scholastic
//
//  Created by John Eddie on 01/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (NSFileManagerExtensions)

- (BOOL)BITfileSystemHasBytesAvailable:(unsigned long long)sizeInBytes;

@end
