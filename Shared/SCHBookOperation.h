//
//  SCHBookOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHBookOperation : NSOperation {
    
}

@property (nonatomic, copy) NSString *isbn;
@property BOOL executing;
@property BOOL finished;

- (void) beginOperation;
- (void) endOperation;
- (void) setIsbnWithoutUpdatingProcessingStatus: (NSString *) newIsbn;

@end
