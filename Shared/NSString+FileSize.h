//
//  NSString+FileSize.h
//  Scholastic
//
//  Created by John S. Eddie on 03/04/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileSize)

+ (id)stringWithSizeInGBFromBytes:(NSInteger)sizeInBytes;

@end
