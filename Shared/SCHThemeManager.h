//
//  SCHThemeManager.h
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHThemeManager : NSObject {
    
}

+ (SCHThemeManager *)sharedThemeManager;

- (NSArray *)themeNames;

@end
