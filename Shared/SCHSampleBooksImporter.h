//
//  SCHSampleBooksManager.h
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHSampleBooksImporter : NSObject {}

- (BOOL)importSampleBooks;
- (BOOL)importLocalBooks;
- (NSUInteger)sampleBookCount;

@end
