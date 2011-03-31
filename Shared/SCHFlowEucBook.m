//
//  SCHFlowEucBook.m
//  Scholastic
//
//  Created by Gordon Christie on 31/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowEucBook.h"

@interface SCHFlowEucBook ()

@property (nonatomic, assign) NSString *isbn;

@end


@implementation SCHFlowEucBook

@synthesize isbn;

- (id)initWithISBN:(NSString *)newIsbn
{
    if((self = [super init])) {
        self.isbn = newIsbn;
    }
    
    return self;
}

- (void)dealloc
{
    self.isbn = nil;
    
    [super dealloc];
}


@end
