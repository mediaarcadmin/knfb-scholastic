//
//  SCHDictionaryWordForm.h
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
extern NSString * const kSCHDictionaryWordForm;

@interface SCHDictionaryWordForm : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSString * baseWordID;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * rootWord;

@end
