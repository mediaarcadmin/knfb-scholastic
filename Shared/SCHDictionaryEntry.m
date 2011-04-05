//
//  SCHDictionaryEntry.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryEntry.h"
#import "SCHDictionaryManager.h"


@implementation SCHDictionaryEntry
@dynamic baseWordID;
@dynamic word;
@dynamic category;
@dynamic fileOffset;


- (NSString *) HTMLforEntry
{
    NSString *result = nil;
    
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    
    NSString *filePath = [[dictManager dictionaryDirectory] stringByAppendingPathComponent:@"EntryTable.txt"];
    
    FILE *file = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    setlinebuf(file);
    char line[6560];
    
    NSLog(@"Seeking to offset %ld", [self.fileOffset longValue]);
    
    fseek(file, [self.fileOffset longValue], 0);
    
    if (fgets(line, 6560, file) != NULL) {
        char *start, *entryID, *headword, *level, *entryXML;
        char *sep = "\t";
        
        start = strtok(line, sep);
        if (start != NULL) {
            entryID = strtok(NULL, sep);                    // MATCH
            if (entryID != NULL) {
                headword = strtok(NULL, sep);
                if (headword != NULL) {
                    level = strtok(NULL, sep);              // MATCH YD/OD
                    if (level != NULL) {
                        entryXML = strtok(NULL, sep);
                        if (entryXML != NULL) {
                            result = [NSString stringWithCString:entryXML encoding:NSUTF8StringEncoding];
                        }
                    }
                }
            }
        }
    }
    
    
    fclose(file);
    
    return result;
}


@end
