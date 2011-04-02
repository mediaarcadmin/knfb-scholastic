//
//  SCHTextFlowParagraphSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 02/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBTextFlowParagraphSource.h"
#import "KNFBParagraphSource.h"

@interface SCHTextFlowParagraphSource : KNFBTextFlowParagraphSource <KNFBParagraphSource> {}

- (id)initWithISBN:(NSString *)isbn;

@end
