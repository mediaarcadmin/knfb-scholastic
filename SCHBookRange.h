//
//  SCHBookRange.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// FIXME: Replace this class with annotations

@interface SCHBookRange : NSObject {
    
}

- (id)initWithStartPage:(NSUInteger)startPage 
             startBlock:(NSUInteger)startBlock
              startWord:(NSUInteger)startWord
                endPage:(NSUInteger)endPage
               endBlock:(NSUInteger)endBlock
                endWord:(NSUInteger)endWord;

@property (nonatomic, assign) NSUInteger startPage;
@property (nonatomic, assign) NSUInteger startBlock;
@property (nonatomic, assign) NSUInteger startWord;
@property (nonatomic, assign) NSUInteger endPage;
@property (nonatomic, assign) NSUInteger endBlock;
@property (nonatomic, assign) NSUInteger endWord;

@end
