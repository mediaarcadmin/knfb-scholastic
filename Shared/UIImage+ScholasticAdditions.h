//
//  UIImage+ScholasticAdditions.h
//  Scholastic
//
//  Created by Matt Farrugia on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ScholasticAdditions)

+ (UIImage *)SCHCreateThumbWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath maxDimension:(NSUInteger)maxDimension;

@end
